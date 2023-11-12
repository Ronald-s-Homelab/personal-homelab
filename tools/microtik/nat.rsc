{
  :local ports ({
  "tcp"=({3074;"27014-27050"});
  "udp"=({3074;3478;27036;"4379-4380";"27000-27031"})
  });

  :foreach k,v in=$ports do={
    :foreach i in=$v do={
      :local inputString "$i"

      # Check if the inputString contains a hyphen ("-")
      :local isRange [:find $inputString "-"]
      :local dstAddr "192.168.88.20"
      # If it's a range
      :if ($isRange > 0) do={
          :local rangeArray [:toarray [:pick $inputString ($isRange+1) [:len $inputString]]]
          :local startPort [:pick $inputString 0 ($isRange)]
          :local endPort [:pick $rangeArray 0]
          :put ("Start Port: " . $startPort . ", End Port: " . $endPort)
          :for port from=$startPort to=$endPort do={
          /ip firewall nat
          add action=dst-nat chain=dstnat disabled=no dst-port=[$port] protocol=$k to-addresses=[$dstAddr] to-ports=[$port]
          }
      } else={
          /ip firewall nat
          add action=dst-nat chain=dstnat disabled=no dst-port=[$inputString] protocol=$k to-addresses=[$dstAddr] to-ports=[$inputString]
      }
     }
  }
}

# /ip firewall nat
# add action=dst-nat chain=dstnat disabled=no dst-address=[X.X.X.X] dst-port=[XXXX] protocol=tcp to-addresses=[X.X.X.X] to-ports=[XXXX]
