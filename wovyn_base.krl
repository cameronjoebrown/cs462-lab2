ruleset wovyn_base {
    meta {
        name "Wovyn Base"
        description << Ruleset for Wovyn Base >>
        author "Cameron Brown"
        use module twilio
            with
                account_sid = meta:rulesetConfig{"account_sid"}
                auth_token = meta:rulesetConfig{"auth_token"}
        shares lastResponse
    }
    global {
        temperature_threshold = 65;
        lastResponse = function() {
            {}.put(ent:lastTimestamp, ent:lastResponse)
        }
        toNumber = "+14352162134"
    }
    rule process_heartbeat {
        select when wovyn heartbeat
        pre {
            log = event:attrs.klog("attrs")
            msg = "The current temperature is: ".klog()
        }
        if event:attrs{"genericThing"} then send_directive("wovyn heartbeat", {"body": msg});
        fired {
            raise wovyn event "new_temperature_reading" attributes {
                "temperature" : event:attrs{"genericThing"}{"data"}{"temperature"}[0]{"temperatureF"},
                "timestamp" : time:now()
            }
        }
    }

    rule find_high_temps {
        select when wovyn new_temperature_reading
        pre {
            temperature = event:attrs{"temperature"}
        }
        fired {
            raise wovyn event "threshold_violation" attributes {
            
            } if temperature > temperature_threshold
        }
    }

    rule threshold_notification {
        select when wovyn threshold_violation
        pre {
            to = toNumber
            sender = "+19402907444"
            message = "It is too hot."
        }
        twilio:send_sms(to, sender, message) setting(response)

        fired {
            ent:lastResponse := response
            ent:lastTimestamp := time:now()
        }
    }
}