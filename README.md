# KalmanFilter
Swift implementation of Conventional Kalman Filter algorithm
##Motivation:
[Kalman filter](https://en.wikipedia.org/wiki/Kalman_filter) is a widely applied algorithm to get a more
accurate guess in noisy environment. It has a lot of applications in real life such as guidance, navigation
control for vehicles, etc. Although I used it to filter GPS data originally, this framework doesn't have a 
ready-to-use solutions that work with GPS and is more general implementation of algorithm.
##Example of usage
`Kalman filter` can work with anything that adopts `KalmanInput` protocol. Framework provides `Matrix` 
struct that conforms to this protocol, although you can use anything that is more suitable for you. For 
example, framework also provides `Double`'s extension with `KalmanInput` and you can use it if your
`KalmanFilter` has only 1 dimension.

The code below is the example of usage of `1D KalmanFilter` taken from 
[here](http://bilgin.esme.org/BitsAndBytes/KalmanFilterforDummies). 
```swift
let measurements = [0.39, 0.50, 0.48, 0.29, 0.25, 0.32, 0.34, 0.48, 0.41, 0.45, 0.46, 0.59, 0.42]
var filter = KalmanFilter(stateEstimatePrior: 0.0, errorCovariancePrior: 1)

for measurement in measurements {
    let prediction = filter.predict(1, controlInputModel: 0, controlVector: 0, covarianceOfProcessNoise: 0)
    let update = prediction.update(measurement, observationModel: 1, covarienceOfObservationNoise: 0.1)
    
    filter = update
}
```
##Sources
All the names of properties and methods' parameters names are taken from 
[wikipedia page](https://en.wikipedia.org/wiki/Kalman_filter#Details).

If you are looking for a good source to understand how `Kalman Filter` works then take a look at 
[this page](http://bilgin.esme.org/BitsAndBytes/KalmanFilterforDummies), 
[this one](http://www.bzarg.com/p/how-a-kalman-filter-works-in-pictures/) and there is a great series of
video tutorials on [udacity](https://www.udacity.com/course/artificial-intelligence-for-robotics--cs373)
##Fields for improvements
The current method of finding inversed matrix used in framework is not very efficient and requires an
implementation with better time complexity.
