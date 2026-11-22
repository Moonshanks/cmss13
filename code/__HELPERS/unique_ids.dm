
var/global/next_uuid = 0

/proc/generate_uuid()
    next_uuid++
    return md5("[world.realtime]-[world.time]-[next_uuid]-[rand(1, 1000000000)]")
