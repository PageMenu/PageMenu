INCREMENTING=${1:-"patch"}
podspec-bump ${INCREMENTING} -w;
PUBLISHING_VERSION=`podspec-bump --dump-version`
git commit -am "Publishing ${PUBLISHING_VERSION}";
git tag "${PUBLISHING_VERSION}";
git push --tags;
pod repo push mv-swift-package-repository project.podspec --verbose --allow-warnings
git push origin;
