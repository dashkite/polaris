import assert from "@dashkite/assert"
import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"

import * as Time from "@dashkite/joy/time"

import { expand } from "../src"
import scenarios from "./scenarios"
import expected from "./expected"
import data from "./data"
import largeData from "./large-data"
import api from "./api"

do ->

  print await test "@dashkite/polaris", [

    test "scenarios", do ->
      for scenario in scenarios
        do ({ name, input, expect } = scenario ) ->
          name ?= input
          test name, ->
            assert.deepEqual expect,
              expand input, data
      

    # I can't test for this as a scenario because JS YAML
    # doesn't support undefined
    test "undefined", ->
      assert.equal undefined, expand "${ foo }", {}
      assert.equal undefined, expand "", {}
      assert.equal "${ foo }", expand "${ foo }", undefined
      assert.equal "", expand "", undefined

    test "nefarious", ->
      data.name = "Bob"
      actual = expand scenarios, data
      assert.notDeepEqual actual, expected

    test "benchmark", ->
      ms = [
        Time.benchmark ->
          expand largeData, largeData 
        Time.benchmark ->
          expand largeData, largeData 
      ] 
      # console.log benchmark: ms
      assert ms[0] < 10
      assert ms[1] < 10
  ]

