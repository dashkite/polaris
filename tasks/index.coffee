import * as t from "@dashkite/genie"
import preset from "@dashkite/genie-presets"
import * as M from "@dashkite/masonry"
import { Module as N } from "@dashkite/genie-modules"
import { File as F } from "@dashkite/genie-files"

preset t

t.define "publish", M.start [
  M.glob "build/browser/**/*", "."
  M.read
  F.changed
  N.data
  N.publish "${ module.name }/${ source.hash }/${ source.path }"
]
