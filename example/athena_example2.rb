# require 'comma-api-rb'

require_relative '../lib/comma-api-rb'

Athena = CommaAPI::Athena

# carState = Athena.carState()
# puts "carState: #{carState}\n\n"

services = %w(
  frame
  sensorEvents
  gpsNMEA
  thermal
  can
  controlsState
  #liveEvent
  model
  features
  health
  radarState
  #liveUI
  encodeIdx
  liveTracks
  sendcan
  logMessage
  liveCalibration
  androidLog
  carState
  carControl
  plan
  liveLocation
  gpsLocation
  ethernetData
  navUpdate
  qcomGnss
  lidarPts
  procLog
  gpsLocationExternal
  ubloxGnss
  clocks
  liveMpc
  liveLongitudinalMpc
  plusFrame
  navStatus
  gpsLocationTrimble
  trimbleGnss
  ubloxRaw
  gpsPlannerPoints
  gpsPlannerPlan
  applanixRaw
  orbLocation
  trafficEvents
  liveLocationTiming
  orbslamCorrection
  liveLocationCorrected
  orbObservation
  applanixLocation
  liveLocationKalman
  uiNavigationEvent
  orbOdometry
  orbFeatures
  orbKeyFrame
  uiLayoutState
  frontEncodeIdx
  orbFeaturesSummary
  driverMonitoring
  liveParameters
  liveMapData
  cameraOdometry
  pathPlan
  kalmanOdometry
  thumbnail
  carEvents
  carParams
  testModel
  testLiveLocation
  testJoystick
)

services.each do |service|
  custom = Athena.getMessage service: service
  puts "custom: #{custom}\n\n"
end


# TODO: these port numbers are hardcoded in c, fix this

# LogRotate: 8001 is a PUSH PULL socket between loggerd and visiond

# all ZMQ pub sub: port, should_log, frequency, (qlog_decimation)
#
# # frame syncing packet
# frame: [8002, true, 20., 1]
# # accel, gyro, and compass
# sensorEvents: [8003, true, 100., 100]
# # GPS data, also global timestamp
# gpsNMEA: [8004, true, 9.]  # 9 msgs each sec
# # CPU+MEM+GPU+BAT temps
# thermal: [8005, true, 2., 1]
# # List(CanData), list of can messages
# can: [8006, true, 100.]
# controlsState: [8007, true, 100., 100]
# #liveEvent: [8008, true, 0.]
# model: [8009, true, 20., 5]
# features: [8010, true, 0.]
# health: [8011, true, 2., 1]
# radarState: [8012, true, 20.]
# #liveUI: [8014, true, 0.]
# encodeIdx: [8015, true, 20.]
# liveTracks: [8016, true, 20.]
# sendcan: [8017, true, 100.]
# logMessage: [8018, true, 0.]
# liveCalibration: [8019, true, 5.]
# androidLog: [8020, true, 0.]
# carState: [8021, true, 100., 10]
# # 8022 is reserved for sshd
# carControl: [8023, true, 100., 10]
# plan: [8024, true, 20.]
# liveLocation: [8025, true, 0.]
# gpsLocation: [8026, true, 1., 1]
# ethernetData: [8027, true, 0.]
# navUpdate: [8028, true, 0.]
# qcomGnss: [8029, true, 0.]
# lidarPts: [8030, true, 0.]
# procLog: [8031, true, 0.5]
# gpsLocationExternal: [8032, true, 10., 1]
# ubloxGnss: [8033, true, 10.]
# clocks: [8034, true, 1.]
# liveMpc: [8035, false, 20.]
# liveLongitudinalMpc: [8036, false, 20.]
# plusFrame: [8037, false, 0.]
# navStatus: [8038, true, 0.]
# gpsLocationTrimble: [8039, true, 0.]
# trimbleGnss: [8041, true, 0.]
# ubloxRaw: [8042, true, 20.]
# gpsPlannerPoints: [8043, true, 0.]
# gpsPlannerPlan: [8044, true, 0.]
# applanixRaw: [8046, true, 0.]
# orbLocation: [8047, true, 0.]
# trafficEvents: [8048, true, 0.]
# liveLocationTiming: [8049, true, 0.]
# orbslamCorrection: [8050, true, 0.]
# liveLocationCorrected: [8051, true, 0.]
# orbObservation: [8052, true, 0.]
# applanixLocation: [8053, true, 0.]
# liveLocationKalman: [8054, true, 0.]
# uiNavigationEvent: [8055, true, 0.]
# orbOdometry: [8057, true, 0.]
# orbFeatures: [8058, false, 0.]
# orbKeyFrame: [8059, true, 0.]
# uiLayoutState: [8060, true, 0.]
# frontEncodeIdx: [8061, true, 5.]
# orbFeaturesSummary: [8062, true, 0.]
# driverMonitoring: [8063, true, 5., 1]
# liveParameters: [8064, true, 10.]
# liveMapData: [8065, true, 0.]
# cameraOdometry: [8066, true, 5.]
# pathPlan: [8067, true, 20.]
# kalmanOdometry: [8068, true, 0.]
# thumbnail: [8069, true, 0.2, 1]
# carEvents: [8070, true, 1., 1]
# carParams: [8071, true, 0.02, 1]
#
# testModel: [8040, false, 0.]
# testLiveLocation: [8045, false, 0.]
# testJoystick: [8056, false, 0.]

# 8080 is reserved for slave testing daemon
# 8762 is reserved for logserver

# manager -- base process to manage starting and stopping of all others
#   subscribes: thermal

# **** processes that communicate with the outside world ****

# thermald -- decides when to start and stop onroad
#   subscribes: health, location
#   publishes: thermal

# boardd -- communicates with the car
#   subscribes: sendcan
#   publishes: can, health, ubloxRaw

# sensord -- publishes IMU and Magnetometer
#   publishes: sensorEvents

# gpsd -- publishes EON's gps
#   publishes: gpsNMEA

# visiond -- talks to the cameras, runs the model, saves the videos
#   publishes:  frame, model, driverMonitoring, cameraOdometry, thumbnail

# **** stateful data transformers ****

# plannerd -- decides where to drive the car
#   subscribes: carState, model, radarState, controlsState, liveParameters
#   publishes:  plan, pathPlan, liveMpc, liveLongitudinalMpc

# controlsd -- drives the car by sending CAN messages to panda
#   subscribes: can, thermal, health, plan, pathPlan, driverMonitoring, liveCalibration
#   publishes:  carState, carControl, sendcan, controlsState, carEvents, carParams

# radard -- processes the radar and vision data
#   subscribes: can, controlsState, model, liveParameters
#   publishes:  radarState, liveTracks

# params_learner -- learns vehicle params by observing the vehicle dynamics
#   subscribes: controlsState, sensorEvents, cameraOdometry
#   publishes: liveParameters

# calibrationd -- reads posenet and applies a temporal filter on the frame region to look at
#   subscribes: cameraOdometry
#   publishes: liveCalibration

# ubloxd -- read raw ublox data and converts them in readable format
#   subscribes: ubloxRaw
#   publishes: ubloxGnss

# **** LOGGING SERVICE ****

# loggerd
#   subscribes: EVERYTHING

# **** NON VITAL SERVICES ****

# ui
#   subscribes: thermal, model, controlsState, uiLayout, liveCalibration, radarState, liveMpc, plusFrame, liveMapData

# uploader
#   communicates through file system with loggerd

# deleter
#   communicates through file system with loggerd and uploader

# logmessaged -- central logging service, can log to cloud
#   publishes:  logMessage

# logcatd -- fetches logcat info from android
#   publishes:  androidLog

# proclogd -- fetches process information
#   publishes: procLog

# tombstoned -- reports native crashes

# athenad -- on request, open a sub socket and return the value

# updated -- waits for network access and tries to update every hour
