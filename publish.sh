podspec-bump -w;
git commit -am "bump `podspec-bump --dump-version`";
git tag "`podspec-bump --dump-version`";
git push --tags;
pod repo push mv-swift-package-repository PageMenu.podspec --verbose;
