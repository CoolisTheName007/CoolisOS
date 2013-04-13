while true do
turtle.suckUp()
while turtle.getItemCount(1)~=0 do
turtle.drop()
end
sleep(1)
end