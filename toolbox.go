package main

import (
	"bytes"
	"errors"
	"fmt"
	"log"
	"math/rand"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"strings"
	"time"

	"github.com/spf13/cobra"
)

func check(err error) {
	if err == nil {
		return
	}
	var errExit *exec.ExitError
	if errors.As(err, &errExit) {
		log.Println(err)
		os.Exit(errExit.ExitCode())
	} else {
		panic(err)
	}
}

func recoverFatal() func() {
	return func() {
		if r := recover(); r != nil {
			log.Fatal(r)
		}
	}
}

func main() {
	rand.Seed(time.Now().UnixNano())

	defer recoverFatal()

	root := &cobra.Command{
		Short: "Toolbox runner.",
	}

	root.AddCommand(bashCmd())
	check(root.Execute())
}

func bashCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "bash",
		Short: "run a bash shell",
		Run: func(cmd *cobra.Command, args []string) {
			upperdir, err := cmd.Flags().GetString("upperdir")
			check(err)

			uid, err := cmd.Flags().GetString("uid")
			check(err)

			gid, err := cmd.Flags().GetString("gid")
			check(err)

			dir := filepath.Join(
				path.Dir(upperdir),
				fmt.Sprintf(".fuse-%d", rand.Int()),
			)
			defer os.RemoveAll(dir)
			defer cleanup(upperdir)

			check(mount(upperdir, dir, uid, gid))
			defer unmount(dir)

			check(runContainer(filepath.Join(dir, "merged")))
		},
	}

	cmd.Flags().String("upperdir", "./code", "upperdir for fuse-overlayfs mount")
	cmd.MarkFlagRequired("upperdir")

	cmd.Flags().String("uid", "3000", "UID of user inside container")
	cmd.MarkFlagRequired("uid")

	cmd.Flags().String("gid", "3000", "GID of user inside container")
	cmd.MarkFlagRequired("gid")

	return cmd
}

func mount(upperdir, dir, containerUID, containerGID string) error {
	lowerdir := filepath.Join(dir, "lowerdir")
	check(os.MkdirAll(lowerdir, 0o755))

	workdir := filepath.Join(dir, "workdir")
	check(os.MkdirAll(workdir, 0o755))

	mountpoint := filepath.Join(dir, "merged")
	check(os.MkdirAll(mountpoint, 0o755))

	cmd := exec.Command(
		"podman",
		"unshare",
		"fuse-overlayfs",
		"-o",
		strings.Join([]string{
			fmt.Sprintf("uidmapping=0:%s:1", containerUID),
			fmt.Sprintf("gidmapping=0:%s:1", containerGID),
			fmt.Sprintf("lowerdir=%s", lowerdir),
			fmt.Sprintf("upperdir=%s", upperdir),
			fmt.Sprintf("workdir=%s", workdir),
			"noxattrs=1",
			"fsync=1",
			"threaded=1",
		}, ","),
		mountpoint,
	)

	var b bytes.Buffer
	cmd.Stderr = &b

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("error mounting FUSE: %s: %w", b.String(), err)
	}

	return nil
}

func unmount(dir string) {
	mountpoint := filepath.Join(dir, "merged")

	for _, v := range []string{"fusermount3", "fusermount"} {
		err := exec.Command("podman", "unshare", v, "-u", mountpoint).Run()
		if err == nil {
			return
		}
		log.Println(fmt.Errorf("error unmounting FUSE: %w", err))
	}
}

func cleanup(upperdir string) {
	if err := filepath.Walk(upperdir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if (info.Mode()&os.ModeCharDevice) != 0 || info.Name() == ".wh..wh..opq" {
			if err := os.Remove(path); err != nil {
				log.Println(err)
			}
		}
		return nil
	}); err != nil {
		log.Println(err)
	}
}

func runContainer(codeDir string) error {
	cmd := exec.Command(
		"podman-compose",
		"-p",
		"dev-env",
		"run",
		"--rm",
		"--service-ports",
		//"-v",
		//fmt.Sprintf("%s:/code", merged), // TODO doesn't work
		"toolbox",
		"/bin/bash",
	)

	cmd.Env = append(os.Environ(), fmt.Sprintf("CODE_DIR=%s", codeDir))

	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	return cmd.Run()
}
