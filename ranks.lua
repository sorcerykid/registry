local register_rank = ...

register_rank( "basic", { color = "#FFFFFF", title = "Basic", label = "", badge = "" } )
register_rank( "guard", { color = "#80FFFF", title = "Guardian", label = "", badge = "", privs = { water = true, lava = true } } )
register_rank( "staff", { color = "#80FF80", title = "Moderator", label = " (staff)", badge = " [STAFF]", privs = { basic_privs = true } } )
register_rank( "admin", { color = "#FFFF80", title = "Administrator", label = " (admin)", badge = " [ADMIN]", privs = { superuser = true } } )
register_rank( "owner", { color = "#FF80FF", title = "Owner/Operator", label = " (owner)", badge = " [OWNER]", privs = { server = true } } )
