
RegisterServerEvent('hudevents:leftVehicle')
AddEventHandler('hudevents:leftVehicle', function(currentVehicle, currentSeat, vehicle_name, net_id)
    TriggerClientEvent('hudevents:leftVehicle', source, currentVehicle, currentSeat, vehicle_name, net_id)
end)

RegisterServerEvent('hudevents:enteredVehicle')
AddEventHandler('hudevents:enteredVehicle', function(currentVehicle, currentSeat, vehicle_name, net_id)	
    TriggerClientEvent('hudevents:enteredVehicle', source, currentVehicle, currentSeat, vehicle_name, net_id)
end)
