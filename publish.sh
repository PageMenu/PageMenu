INCREMENTING=${1:-"patch"}
podspec-bump ${INCREMENTING} -w;
git commit -am "Publishing `podspec-bump --dump-version`";
git tag "`podspec-bump --dump-version`";
git push --tags;
pod repo push mv-swift-package-repository PageMenu.podspec --verbose;
git push origin master;
