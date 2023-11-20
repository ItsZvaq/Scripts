if not getgenv().LPH_NO_VIRTUALIZE then 
    getgenv().LPH_NO_VIRTUALIZE = function(...)
        return coroutine.wrap(...)
    end
end
