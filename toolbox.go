package main

import (
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

func fatal(err error) {
	if err != nil {
		panic(err)
	}
}

func warn(err error) {
	if err != nil {
		log.Println(err)
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
	fatal(root.Execute())
}

func bashCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "bash",
		Short: "run a bash shell",
		Run: func(cmd *cobra.Command, args []string) {
			upperdir, err := cmd.Flags().GetString("upperdir")
			fatal(err)

			uid, err := cmd.Flags().GetString("uid")
			fatal(err)

			gid, err := cmd.Flags().GetString("gid")
			fatal(err)

			dir := filepath.Join(
				path.Dir(upperdir),
				fmt.Sprintf(".fuse-%d", rand.Int()),
			)
			defer os.RemoveAll(dir)
			defer cleanup(upperdir)

			mount(upperdir, dir, uid, gid)
			defer unmount(dir)

			runContainer(filepath.Join(dir, "merged"))
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

func mount(upperdir, dir, containerUID, containerGID string) {
	lowerdir := filepath.Join(dir, "lowerdir")
	fatal(os.MkdirAll(lowerdir, 0o755))

	workdir := filepath.Join(dir, "workdir")
	fatal(os.MkdirAll(workdir, 0o755))

	mountpoint := filepath.Join(dir, "merged")
	fatal(os.MkdirAll(mountpoint, 0o755))

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

	fatal(cmd.Run())
}

func unmount(dir string) {
	mountpoint := filepath.Join(dir, "merged")

	for _, v := range []string{"fusermount3", "fusermount"} {
		err := exec.Command("podman", "unshare", v, "-u", mountpoint).Run()
		if err == nil {
			return
		}
		warn(fmt.Errorf("error unmounting FUSE: %w", err))
	}
}

func cleanup(upperdir string) {
	err := filepath.Walk(upperdir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if (info.Mode()&os.ModeCharDevice) != 0 || info.Name() == ".wh..wh..opq" {
			warn(os.Remove(path))
		}
		return nil
	})

	warn(err)
}

func runContainer(codeDir string) {
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

	fatal(cmd.Run())
}
