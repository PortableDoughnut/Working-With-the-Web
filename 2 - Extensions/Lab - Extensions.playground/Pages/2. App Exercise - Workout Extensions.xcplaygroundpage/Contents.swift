/*:
## App Exercise - Workout Extensions

 >These exercises reinforce Swift concepts in the context of a fitness tracking app.

 Add an extension to the `Workout` struct below and make it adopt the `CustomStringConvertible` protocol.
 */
struct Workout {
    var distance: Double
    var time: Double
    var averageHR: Int
}

extension Workout: CustomStringConvertible {
	var description: String {
		"""
You ran \(distance) meters in \(time) time. 
Your average heart rate was \(averageHR) and your average speed was \(speed) meters per second.
"""
	}
}

//:  Now create another extension for `Workout` and add a property `speed` of type `Double`. It should be a computed property that returns the average meters per second traveled during the workout.
extension Workout {
	var speed: Double {
		distance / time
	}
}

//:  Now add a method `harderWorkout` that takes no parameters and returns another `Workout` instance. This method should double the `distance` and `time` properties, and add 40 to `averageHR`. Create an instance of `Workout` and print it to the console. Then call `harderWorkout` and print the new `Workout` instance to the console.
extension Workout {
	func harderWorkout() -> Workout {
		.init(distance: distance * 2, time: time * 2, averageHR: averageHR + 40)
	}
}

var myWorkout: Workout = .init(distance: 20, time: 8, averageHR: 92)
print(myWorkout)

print(myWorkout.harderWorkout())
/*:
 _Copyright © 2023 Apple Inc._

 _Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:_

 _The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software._

 _THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE._
 
[Previous](@previous)  |  page 2 of 2
 */
