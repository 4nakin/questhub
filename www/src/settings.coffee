define [], ->
    settings =
        service_name: "Questhub"
        mixpanel_id: "eb4a537d40eb92da515db8c18c415de4"
        analytics: "UA-36251424-2"

    if window.location.host in ["localhost:3000", "localhost:3001", "127.0.0.1:3000", "127.0.0.1:3001"]
        settings.analytics = undefined
        settings.mixpanel_id = "f3c2bc81bd754efae836aae54fb42a5a"
    settings

