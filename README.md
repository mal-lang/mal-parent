# MAL Parent

Provides common dependency management and plugin management for MAL projects.

## Release

To make a release, run:

```shell
git checkout master

release_version=1
development_version=2-SNAPSHOT

mvn release:prepare \
  -DpushChanges=false \
  -DreleaseVersion=$release_version \
  -Dtag=release/$release_version \
  -DdevelopmentVersion=$development_version
```

This will create two commits and one tag, e.g.

```
33852fe (HEAD -> master) [maven-release-plugin] prepare for next development iteration
ce82e39 (tag: release/1) [maven-release-plugin] prepare release release/1
```

Push the release commit to github and wait for the travis build to finish:

```shell
git push origin HEAD^:master
```

Push the development commit and the release tag to github:

```shell
git push origin master
git push origin release/$release_version
```

## License

Copyright © 2020 [Foreseeti AB](https://www.foreseeti.com/)

Licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0).
