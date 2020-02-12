require! {
  \require-ls
  \./services/http-service.ls : { start-http-service, start-https-service }
  #\./services/rate-service.ls : { rate-service }
  #\./services/invoice-service.ls : { invoice-service }
  \./services.ls : { register-service: $, start-all }
  \./config.json : { port }
}

$ "http #{port}"     , start-http-service
#$ "rate loader"      , rate-service
#$ "invoice service"  , invoice-service

start-all!

process.on \uncaughtException , console~error