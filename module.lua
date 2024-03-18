-- Cache frequently used _G[*] functions for performance
local require, error, vtable_bind, tostring = require, error, vtable_bind, tostring

-- Dependencies
local ffi = require "ffi"

-- Cache frequently used string.* functions for performance
local string_match = string.match

-- Cache frequently used ffi.* functions for performance
local ffi_metatype, ffi_string, ffi_typeof = ffi.metatype, ffi.string, ffi.typeof

-- Define renderadapterinfo_t: replica of the struct from https://gitlab.com/KittenPopo/csgo-2018-source/-/blob/main/public/rendersystem/irenderdevice.h#L51
local renderadapterinfo_t = ffi_typeof([[
    struct {
        char m_pDriverName[512];
        unsigned int m_VendorID;
        unsigned int m_DeviceID;
        char pad[0x19];
    }
]])

-- Initialize virtual functions
local native_GetCurrentAdapter = vtable_bind("materialsystem.dll", "VMaterialSystem080", 25, "int(__thiscall*)(void*)")
local native_GetAdapterInfo = vtable_bind("materialsystem.dll", "VMaterialSystem080", 26, "void(__thiscall*)(void*, int, $*)", renderadapterinfo_t)

local fallback = {
    driver_name = function(self) return ffi_string(self.m_pDriverName) end,
    vendor_id = function(self) return string_match(tostring(self.m_VendorID), "%d+") end,
    device_id = function(self) return string_match(tostring(self.m_DeviceID), "%d+") end
}

ffi_metatype(renderadapterinfo_t, {
    __index = function(index) return fallback[index](self) or nil end
})

local get_adapter_info = function(adapter)
    local info, adapter = renderadapterinfo_t()
    native_GetAdapterInfo(adapter, info)

    return info
end
