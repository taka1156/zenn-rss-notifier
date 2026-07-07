// Learn more about moon.mod configuration:
// https://docs.moonbitlang.com/en/latest/toolchain/moon/module.html
//
// To add a dependency, run this command in your terminal:
//   moon add moonbitlang/x
//
// Or manually declare it in `import`, for example:
// import {
//   "moonbitlang/x@0.4.6",
// }

name = "taka1156/zenn-rss-notifier"

version = "0.1.0"

readme = "README.md"

repository = "https://github.com/taka1156/zenn-rss-notifier"

license = "Apache-2.0"

keywords = []

preferred_target = "native"

description = ""

import {
  "moonbitlang/async@0.20.1",
  "moonbitlang/x@0.4.46",
}
