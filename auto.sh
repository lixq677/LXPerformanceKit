#!/bin/bash

pod lib lint --allow-warnings --sources="http://git.bngrp.com/retailer-newapp/BNIosProjects/BNSpecs/bnspec.git,https://github.com/CocoaPods/Specs.git"

if [ $? -ne 0 ]; then
    echo "本地验证失败"
    exit 
fi

echo "本地验证成功"

git add .

if [ $? -ne 0 ]; then
    echo "git 添加文件"
    exit
fi
echo "添加代码成功!!!"

git pull

if [ $? -ne 0 ]; then
    echo "git pull 失败"
    exit
fi



git commit -m "修改代码"

if [ $? -ne 0 ]; then
    echo "提交代码失败"
    exit
fi
echo "提交代码成功"
git push 

if [ $? -ne 0 ]; then
    echo "上传代码失败"
    exit
fi
echo "上传代码成功"

git tag "$1"
if [ $? -ne 0 ]; then
    echo "打tag失败"
    exit
fi

echo "打tag成功"

git push --tags
if [ $? -ne 0 ]; then
    echo "上传tag失败"
    exit
fi
echo "上传成功"

pod spec lint --allow-warnings --sources="http://git.bngrp.com/retailer-newapp/BNIosProjects/BNSpecs/bnspec.git,https://github.com/CocoaPods/Specs.git"
git push --tags
if [ $? -ne 0 ]; then
    echo "远程验证失败"
    exit
fi
echo "远程验证成功"

pod repo push bngrp-retailer-newapp-bniosprojects-bnspecs-bnspec LXPerformanceKit.podspec --allow-warnings --sources="http://git.bngrp.com/retailer-newapp/BNIosProjects/BNSpecs/bnspec.git,https://github.com/CocoaPods/Specs.git"
if [ $? -ne 0 ]; then
    echo "入库失败"
    exit
fi
echo "入库成功"
