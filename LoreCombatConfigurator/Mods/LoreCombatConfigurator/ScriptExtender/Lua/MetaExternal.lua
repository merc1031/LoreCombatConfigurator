--- @meta
--- @diagnostic disable

--- @class Ext_Json
--- @field Parse fun(a1:string): table
--- @field Stringify fun(a1:table, a2:any): string
local Ext_Json = {}

--- @class Ext_Types
--- @field Serialize fun(a1:any): any
local Ext_Types = {}

--- @class Ext_IO
--- @field SaveFile fun(a1:string, a2:string)
local Ext_IO = {}

--- @alias ListenerCallback0 fun()
--- @alias ListenerCallback1 fun(a1: any)
--- @alias ListenerCallback2 fun(a1: any, a2: any)
--- @alias ListenerCallback3 fun(a1: any, a2: any, a3:any)
--- @alias ListenerCallback4 fun(a1: any, a2: any, a3:any, a4:any)

--- @alias ListenerCallback ListenerCallback0 | ListenerCallback1 | ListenerCallback2 | ListenerCallback3 | ListenerCallback4

--- @class Ext
--- @field Osiris table
local Ext = {}

--- @param event string
--- @param arity integer
--- @param when string
--- @param handler ListenerCallback
function Ext.Osiris.RegisterListener(event, arity, when, handler) end

--- @class UserVarSettings
--- @field Server boolean
--- @field Persistent boolean
--- @field DontCache boolean

--- @class Ext_Vars
--- @field RegisterUserVariable fun(a1:string, a2:UserVarSettings)
local Ext_Vars = {}
