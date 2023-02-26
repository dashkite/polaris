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

    test "scenarios", ->
      actual = expand scenarios, data
      console.log actual
      assert.deepEqual actual, expected

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
      console.log benchmark: ms
      assert ms[0] < 10
      assert ms[1] < 10
  ]

