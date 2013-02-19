{ Monarch } = require "../spec_helper"
{ visit } = Monarch.Util

describe "Visitor", ->
  class AcceptingClass
  class NonAcceptingClass
  class OtherClass
  visit.setup(AcceptingClass, "SomeModule", "AcceptingClass")

  SomeVisitor =
    name: "some-visitor"
    visit: visit,
    visit_null: (obj, arg) ->
      "#{@name} visited null with #{arg}"
    visit_SomeModule_AcceptingClass: (obj, arg) ->
      "#{@name} visited accepting class with #{arg}"
    visit_NonAcceptingClass: (obj, arg) ->
      "#{@name} visited non-accepting class with #{arg}"

  describe "#visit", ->
    describe "when the visitee has been setup", ->
      it "calls that method, passing itself and any other arguments to #visit", ->
        expect(SomeVisitor.visit(new AcceptingClass, 1)).toBe(
          "some-visitor visited accepting class with 1")

    describe "when the visitee has no #acceptVisitor method", ->
      describe "when the visitor has a visit method for the visitee's class", ->
        it "calls that method, passing itself and other arguments to #visit", ->
          expect(SomeVisitor.visit(new NonAcceptingClass, 2)).toBe(
            "some-visitor visited non-accepting class with 2")

      describe "when the visitor has no visit method for the visitee's class", ->
        it "throws an exception", ->
          expect(->
            SomeVisitor.visit(new OtherClass)
          ).toThrow(new Error("Cannot visit OtherClass"))

    describe "when the visitee is null", ->
      it "calls the visit_Null method", ->
        expect(SomeVisitor.visit(null, 2)).toBe(
          "some-visitor visited null with 2")

    describe "when no visitee is passed", ->
      it "throws an exception if no object is passed", ->
        expect(-> SomeVisitor.visit()).toThrow(
          new Error("Cannot visit undefined"))

