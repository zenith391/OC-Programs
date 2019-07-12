local GERTi = require("GERTiClient")
local computer = require("computer")
local gdns = {}
local dnsAddress = 0.7 -- configure default depending on your environment

function gdns.setDNSAddress(addr)
  dnsAddress = addr
end

function gdns.getDNSAddress()
  return dnsAddress
end

function gdns.resolve(domain)
  local socket = GERTi.openSocket(dnsAddress)
  socket:write(domain)
  -- Read with timeout
  local deadline = computer.uptime() + 5
  local read = socket:read()
  while #read == 0 do
    if computer.uptime() >= deadline then
      socket:close()
      return false, "timed out"
    end
    os.sleep(0.1)
    read = socket:read()
  end
  local data = read[1] -- awaiting only 1 value
  socket:close()
  if data == -1.0 then -- default invalid address used to specify address isn't found
    return false, "not found"
  else
    return data
  end
end
gdns.request = gdns.resolve -- shortcut

return gdns
