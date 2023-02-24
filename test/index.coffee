import assert from "@dashkite/assert"
import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"

import * as Time from "@dashkite/joy/time"

import { expand } from "../src"
import scenarios from "./scenarios"
import expected from "./expected"
import data from "./data"
import api from "./api"

do ->

  print await test "@dashkite/polaris", [

    test "scenarios", ->
      actual = expand scenarios, data
      assert.deepEqual actual, expected

    test "benchmark", ->
      ms = Time.benchmark ->
        expand [ api, api, api ], { data..., api }
      console.log benchark: ms
      assert ms < 15
      assert.deepEqual [ api, api, api ],
        expand [ api, api, api ], { data..., api }
  ]

