onLadder = nil


local w, h = guiGetScreenSize ()
function updateCamera ()

	local x,y,z = getElementPosition(localPlayer)
	if z > 200 then
		setElementVelocity ( localPlayer,0,0,-10 )
	end
	
	if getPedControlState(localPlayer,'forwards') and getKeyState((getElementData(localPlayer,'Jump [Has to match MTA bind]') or 'lshift'))then
		local x,y,z = getCameraMatrix()
		
		local xa,ya,za = getWorldFromScreenPosition (w/2, h/2, 2)
		
		local hit,xb,yb,zb,hitElement = processLineOfSight (x,y,z,xa,ya,za,true,true,false )
		
		if hit and hitElement then
			if (getElementID(hitElement) == 'Latter') or (getElementID(hitElement) == 'Ladder001') then
				local sx,sy,sz = (-(x-xb)),(-(y-yb)),0.05
				onLadder = {sx,sy,sz,50}
				setElementVelocity ( localPlayer,sx,sy,sz )
				local x,y,z = getElementPosition(localPlayer)
				setElementPosition(localPlayer,x,y,z+0.01)
			end
		end
		if onLadder then
			
			local x,y,z,t = unpack(onLadder)
			setElementVelocity ( localPlayer,x,y,z )
			onLadder = {x,y,z,t-1}
			if t < 0 then
				onLadder = nil
			end
		end
	end
end
addEventHandler ( "onClientRender", root, updateCamera )