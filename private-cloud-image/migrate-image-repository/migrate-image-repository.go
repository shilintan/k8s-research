package main

import (
	"gopkg.in/yaml.v3"
	"log"
	"os"
	"path/filepath"
)

func main() {
	var files []string
	root := "private-cloud-image/migrate-image-repository"
	err := filepath.Walk(root, func(path string, info os.FileInfo, err error) error {
		if info.IsDir() {
			return nil
		}
		if info.Name() == "image-mapping-2-original.yaml" {
			files = append(files, path)
		}
		return nil
	})
	if err != nil {
		panic(err)
	}
	shResult := `apt install -y buildah
buildah login -u "$(cat container_username)" --password-stdin < container_password "https://registry.cn-shanghai.aliyuncs.com"

`
	for _, file := range files {
		content, err := os.ReadFile(file)
		if err != nil {
			log.Fatal(err)
		}
		yamlFileContent := make(map[string]map[string][]map[string]string)
		err = yaml.Unmarshal(content, &yamlFileContent)
		if err != nil {
			log.Fatalf("yarm parse error: %v", err)
		}
		for _, vR := range yamlFileContent {
			for _, vF := range vR {
				for _, iF := range vF {
					iS := iF["s"]
					iT := iF["t"]
					shResult += "buildah pull " + iS
					shResult += "\n"
					shResult += "buildah tag " + iS + " " + iT
					shResult += "\n"
					shResult += "buildah push " + iT
					shResult += "\n"

					shResult += "buildah rmi " + iS + " " + iT
					shResult += "\n"

					shResult += "\n"
				}
			}
		}
	}
	print(shResult)
	err = os.WriteFile("private-cloud-image/migrate-image-repository/sh.sh", []byte(shResult), 0644)
	if err != nil {
		log.Fatalf("write file error: %v", err)
	}
}
