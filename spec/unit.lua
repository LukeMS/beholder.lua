local beholder = require 'beholder'

describe("Unit", function()

  before(function()
    beholder:reset()
  end)

  describe(":observe", function()
    it("notices simple events so that trigger works", function()
      local counter = 0
      beholder:observe("EVENT", function() counter = counter + 1 end)
      beholder:trigger("EVENT")
      assert_equal(counter, 1)
    end)

    it("remembers if more than one action is associated to the same event", function()
      local counter1, counter2 = 0,0
      beholder:observe("EVENT", function() counter1 = counter1 + 1 end)
      beholder:observe("EVENT", function() counter2 = counter2 + 1 end)
      beholder:trigger("EVENT")
      assert_equal(counter1, 1)
      assert_equal(counter2, 1)
    end)

    it("allows observing composed events", function()
      local counter = 0
      beholder:observe("KEYPRESS", "start", function() counter = counter + 1 end)
      beholder:trigger("KEYPRESS", "start")
      assert_equal(counter, 1)
    end)
  end)

  describe(":stopObserving", function()
    it("stops noticing events so trigger doesn't work any more", function()
      local counter = 0
      local id = beholder:observe("EVENT", function() counter = counter + 1 end)
      beholder:trigger("EVENT")
      beholder:stopObserving(id)
      beholder:trigger("EVENT")
      assert_equal(counter, 1)
    end)

    it("stops observing one id without disturbing the others", function()
      local counter1, counter2 = 0,0
      local id1 = beholder:observe("EVENT", function() counter1 = counter1 + 1 end)
      beholder:observe("EVENT", function() counter2 = counter2 + 1 end)
      beholder:trigger("EVENT")

      assert_equal(counter1, 1)
      assert_equal(counter2, 1)
      beholder:stopObserving(id1)
      beholder:trigger("EVENT")

      assert_equal(counter1, 1)
      assert_equal(counter2, 2)

    end)

    it("passes parameters to the actions", function()
      local counter = 0

      beholder:observe("EVENT", function(x) counter = counter + x end)
      beholder:trigger("EVENT", 1)

      assert_equal(counter, 1)
      beholder:trigger("EVENT", 5)

      assert_equal(counter, 6)
    end)

    it("does not raise an error when stopping observing an inexisting event", function()
      assert_not_error(function() beholder:stopObserving({}) end)
    end)

    it("returns false when no action was found for an id", function()
      assert_equal(false, beholder:stopObserving({}))
    end)

    it("returns true when an action was found and removed", function()
      local id = beholder:observe("X", function() end)
      assert_true(beholder:stopObserving(id))
    end)

  end)

  describe(":trigger", function()
    it("does not error on random stuff", function()
      assert_not_error(function() beholder:trigger("FOO") end)
    end)

    it("returns false on events with no actions", function()
      assert_equal(false, beholder:trigger("FOO"))
    end)

    it("returns false if there was a node with no actions", function()
      beholder:observe("ONE","TWO", function() end)
      assert_equal(false, beholder:trigger("ONE"))
    end)

    it("returns the number of actions executed", function()
      beholder:observe("X", function() end)
      beholder:observe("X", function() end)
      assert_equal(2, beholder:trigger("X"))
    end)

  end)


  describe(":reset", function()

  end)


end)
