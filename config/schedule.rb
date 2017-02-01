every 10.minutes do
  runner "GetDataFromTeachbaseJob.perform_now"
end
