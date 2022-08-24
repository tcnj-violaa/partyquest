pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
#include party_new.p8:b

--our string can be, maximum,
--the number of characters possible


--new scheme: reserve some space
--to use as an index to other
--items in the bank
--171 at start for misc info.
--500 bytes (250 ints), sufficient to 
--index up to 250 items of 66 char length


res_addr=0x0
res_end=0x0+171
idx_addr=res_end+1
idx_end=idx_addr+500
bank_addr=idx_end+1
bank_end=0x42ff

--idx_cur_addr=idx_addr
--bank_cur_addr=bank_addr
--written_yet=false

--	local tlk = minnir.anims['talk']
--	tlk.x=split("16,16")
--	tlk.y=split("61,61")
--	tlk.fl_offset=-8
--	tlk.anim_seq={{{17,18}},{{75,76}}}
--	tlk.seq_delay=split("5,8")

lines={"minnir|say|this dialog was stored in a separate cartridge! how cool is that?;alder|say|quite cool;torte|say|this changes everything!;feryn|say|now we can have a really really really long story if we wanted. that's absolutely fantastic if you ask me.;minnir|react|{ald=5,tort=5,fer=5;alder|react|{minn=5,tort=5,fer=5};torte|react|{minn=5,ald=5,fer=5};feryn|react|{minn=5,ald=5,tort=5}`","alder|say|this is the second set of commands in memory...`","feryn|say|this is the third command stored in another cartridge!`",
							"16,16`","61,61`","-8`","{{{17_18}},{{75_76}}}`","5,8`"}
names={"test1","test2","test3",
							"mtlkx","mtlky","mtlkfl","mtlkas","mtlksd"}

function store(write)
	local write = write or true
	local idx_cur_addr=idx_addr
	local bank_cur_addr=bank_addr
	local len=0
	local next_addr=nil
	for i=1,#lines do
		poke2(idx_cur_addr,bank_cur_addr)
		
		len,next_addr=pokestr(lines[i],bank_cur_addr) 
		--len,next_addr=pokestr("minnir|say|this dialog was stored in a separate cartridge! how cool is that?;alder|say|quite cool;torte|say|this changes everything!;feryn|say|now we can have a really really really long story if we wanted. that's absolutely fantastic if you ask me.;minnir|react|{ald=5,tort=5,fer=5;alder|react|{minn=5,tort=5,fer=5};torte|react|{minn=5,ald=5,fer=5};feryn|react|{minn=5,ald=5,tort=5}`",cur_addr)
		--bake it into the rom
		if(write) then
			cstore(idx_cur_addr,idx_cur_addr,2)
			cstore(bank_cur_addr,bank_cur_addr,len)
			--written_yet=true
			print("wrote data to rom. ("..i..")")
		end
		
		bank_cur_addr=next_addr
		idx_cur_addr+=2
	end
end

function clear()
	memset(res_addr,0,bank_end)
	cstore(res_addr,res_addr,bank_end)
	print("stored contents cleared.")
end
--len,next_addr=pokestr("alder|say|this is the second set of commands in memory...`",next_addr)
--
--cstore(next_addr,next_addr,len)

--store next address in shared memory. don't need to read from cart
--poke2(0x4300,next_addr)
--poke2(0x4302,len)

--clear()
--store()

--table of contents
--contents reflect what should be
--present based on names and lines
function tcont()
	store(false)
	printh("contents")
	printh("--------")
	local offsetsum=0
	for i=1,#lines do 
		idx=peek2(idx_addr+(2*i-1))
		str,len=peekstr(bank_addr+offsetsum)
		printh(names[i].." @ lines["..i.."] = "..
									bank_addr+offsetsum.." : '"
									.. str.."'")
		offsetsum+=len
	end
	printh("--------")
	print("contents output to console.")
end
-->8
--misc notes and code


	
--indexing scheme:
--accessible cart space:
--0x0 -> 0x42ff (17151 bytes)
--usable free space:
--0x4300->0x5dff (6911 bytes)
--(17151/3) = 5717 bytes...
--so dividing into 3 banks
--will give us individual
--chunks that fit into working ram

--we have windows of 5717 bytes
--sections={0,1,2}
--we just need to know what section
--a line starts in; loading can span
--two sections just fine

--offset=section*5717+offset


--function peekrange(st_addr,end_addr)
--	printh("peekrange---")
--	local str=""
--	local curchar=""
--	for i=st_addr,end_addr do 
--		curchar=chr(@(i))
--		cur2bytes=@(i)
--		printh("curchar: "..curchar)
--		printh("curval: "..curval)
--		str=str..curchar
--	end
--	return str
--end

	
--function gradient_on()
--	poke(0x5f2c,0x40)
--	--swap 0x3c for 0x3n where n is the color that will be swapped for the gradient
--	poke(0x5f5f,0x3c)
--	for i=0,15 do
--	 --put the gradient colors in the table below:
--	 poke(0x5f60+i,({[0]=0x6c+128,0x6c,0x6c,0x6c,4,4,0x89,0x89,0x8e,0x8e,0x8f,0x8f,15,15,0x87,0x87})[i])
--	end
--	for i=0,15 do
--	 poke(0x5f70+i,0xaa)
--	end
--end
--
--function color_draw()
--	poke(0x5f2c,0x40)
--	poke(0x5f5f,0x3c)
--	--poke(0x5f62)
--end

--recursive args split--

--res_tbl={}
--string=str
--symbol=nil
--idx=1
--
--
--function nextsym()
--	idx+=1
--	symbol=sub(string,idx,idx)
--end
--
--function acc(s)
--	if symbol==s then 
--		nextsym()
--		return 1
--	end
--	return 0	
--end
--
--function exp(s)
--	if accept(s) return 1 else return 0
--end
--function exp(s,e)
--	if acc(s,e) return true
--	else
--	return false
--end 
--
--function brackets_handler(subst)
--//handle	
--end
--
--function rest_handler(subst)
--//handle
--end
--
--function args_split(str,delim)
--	printh("str: "..str)
--	for i=1,#str do
--		local char=sub(str,i,i)
--		local rest=sub(str,i,#str)
--		if char=="{" then
--			//handle brackets
--			local b_ind=i
--			
--		end
--	

--function args_split(str)
--	local spl={}
--	local opens=0
--	local closes=0
--	
--	for i=1,#str do
--		local char=sub(str,i,i)
--			if char=="{" then
--				opens+=1

--function args_split(str)
--	printh("running...")
--	local spl={}
--	local absmap={}
--	local dims=1
--	for i=1,#str do add(absmap,true) end
--	
--	local char=sub(str,1,1)
--	
----	printh(#absmap)
----	printh(#str)
--	if char~="{" then return 0
--	else
--	 absmap[1]=false
--	 absmap[#str]=false
--	end
--	
--	for i=1,#str-2 do
--		local char=sub(str,i,i+2)
--			local one=sub(char,i,i)
--			if one=="{" and absmap[one]~=false then dims+=1 end
--			if char=="},{" and dims<=2 then
--				for j=i,i+2 do
--					absmap[j]=false
--				end
--			end
--	end
--				
--	local abs_ranges={}
--	local st=0
--	local e=0
--		for i=1,#str do
--			if absmap[i]==true then
--				if st==0 then st=i end
--			end
--			if absmap[i]==false then
--				if st>0 then 
--					e=i-1
--					add(abs_ranges,{st,e})
--					st=0
--					e=0
--				end
--			end
--		end
--	
--		
--		for idx,val in pairs(abs_ranges) do
--			printh(idx..val[1]..val[2])
--			--recurse into our abstract 'ranges'
--			add(spl,args_split(sub(str,val[1],val[2])))
--		end
--	
--	return spl
--end						
--
--function tars()
--	test=args_split("{{10,11},{12,13}}")
--end				

--generate anim_xs for sprites
--that don't move at all,
--or dx/dys for sprites that 
--don't translate, or const delays
--function const_seq(
--															num_frames,val)
--	table={}
--	for i=1,num_frames do
--		table[i]=val
--	end
--	return table
--end



__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a202240d540f9406a40da401b408c4000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000d696e6e69627c7371697c74786963702469616c6f67602771637023747f627
56460296e6021602375607162716475602361627472796467656120286f6770236f6f6c60296370247861647f3b316c6465627c7371697c717579647560236f6
f6c6b347f6274756c7371697c74786963702368616e6765637025667562797478696e67612b366562797e6c7371697c7e6f677027756023616e6028616675602
1602275616c6c69702275616c6c69702275616c6c69702c6f6e676023747f62797029666027756027716e6475646e20247861647723702162637f6c6574756c6
97026616e64716374796360296660297f657021637b602d656e2b3d696e6e69627c72756163647c7b716c646d353c247f62747d353c2665627d353b316c64656
27c72756163647c7b7d696e6e6d353c247f62747d353c2665627d353d7b347f6274756c72756163647c7b7d696e6e6d353c216c646d353c2665627d353d7b366
562797e6c72756163647c7b7d696e6e6d353c216c646d353c247f62747d353d7060016c6465627c7371697c7478696370296370247865602375636f6e6460237
564702f6660236f6d6d616e646370296e602d656d6f62797e2e2e2060066562797e6c7371697c747869637029637024786560247869627460236f6d6d616e646
023747f62756460296e60216e6f647865627023616274727964676561206001363c2136306006313c263130600d2830600b7b7b71373f51383d7d7c2b7b77353
f57363d7d7d7060653c2830606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
