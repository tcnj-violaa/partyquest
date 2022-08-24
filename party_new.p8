pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--notes
--if i ever make this a game...
--nonviolence/party quest?
--manage hp,satisfaction, and
--party relationships

 	
--??can we do 'voices' for each character?
--i think we can. do the same thing you did with
--sprites just with passing voice nums
-- dialogue text box library by oli414. minimized.
-- added sprite drawing. +sprite queue,
-- dtb_dsp accepts a sprite and adds it
-- to queue, dtb__nexttext removes
-- from queue, and dtb_draw draws
-- the sprite. 

--july 9th, 2020, 4:30 pm
--tokens before optims=3895
--tokens after optims=3315
--saved 580 tokens!
--...and then added the interpreter
--lmfao. back up to like 4k. hopefully
--this will save tokens in the long run for 
--longer scripts


	--split for minimal tokens,
	--const_seq for minimal chars



-->8
--ui code--
--menu overlord stack--
menu_stack={}

--menu class--
--should handle 'stacked' menus,
--where menus spawn menus

menu={}
menu.w=10
menu.h=10
menu.x=1
menu.y=1
menu.spc=1
menu.curopt=1
menu.opts={}
menu.optfcts={}
menu.numopts=0
menu.up=false
menu.s_bhv=function()return nil end
--menu.upd_fct
--global pick value
--pick_val=nil
function menu:new(o)
	o = o or {}
	o = dcpy(self)
	setmetatable(o,self)
	self.__index=self
	return o
end

function menu:setopts(opts)
	self.opts=split(opts)
	self.numopts=#self.opts
	local rem_spc=(self.h-6)-(6*self.numopts)
	self.spc=flr(rem_spc/self.numopts)
end

function menu:init(shape,ops)
	local sh=split(shape)
	self.x=sh[1]
	self.y=sh[2]
	self.w=sh[3]
	self.h=sh[4]
	self:setopts(ops)
end
	
function menu:update()
--basic option selector--
	if(btnp(2)) then
		self.curopt-=1
		if self.curopt<1 then 
			self.curopt=self.numopts
		end
		sfx(3)
	end
	if(btnp(3)) then
		self.curopt+=1
		if self.curopt>self.numopts then
			self.curopt=1
		end
		sfx(3)
	end
	
	if(btnp(4)) then
		sfx(4)

--		pop(menu_stack)--for testing
--		pause(60)
	
		self.s_bhv()
		return self.curopt
	end
		
end

function pick_dot(x,y)
	circfill(x,y,1,8)
	line(x-1,y,x-1,y,15)--cover up pixel lol
end

--test_s={"even rats", "absolutely not","three","four","five"}
function menu:draw()

	rectfill(self.x,self.y,
									self.x+self.w,
									self.y+self.h,
									15)
	rect(self.x+1,self.y+1,
									self.x+self.w-1,
									self.y+self.h-1,
									4)
	for idx,s in pairs(self.opts) do
		print(s,self.x+8,self.y+(6+self.spc)*(idx-1)+3,1)
	end
	--print(self.curopt,0,0)
	pick_dot(self.x+4,self.y+(6+self.spc)*(self.curopt-1)+5)
end
	
-->8
--dtb and actor class--
function dtb_init(n) dtb_q={}dtb_f={}dtb_sp={}dtb_a={}a_ran=false dtb_n=3 if n then dtb_n=n end _dtb_c() end function dtb_disp(t,c,sp,a)local s,l,w,h,u s={}l=""w=""h=""u=function()if #w+#l>23 then add(s,l)l=""end l=l..w w=""end for i=1,#t do h=sub(t,i,i)w=w..h if h==" "then u()elseif #w>22 then w=w.."-"u()end end u()if l~=""then add(s,l)end add(dtb_q,s)if c==nil then c=0 end add(dtb_f,c) if sp==nil then sp={{5,5},{5,5}} end add(dtb_sp,sp) if a==nil then a=0 end add(dtb_a,a)end function _dtb_c()dtb_d={}for i=1,dtb_n do add(dtb_d,"")end dtb_c=0 dtb_l=0 end function _dtb_l()dtb_c+=1 for i=1,#dtb_d-1 do dtb_d[i]=dtb_d[i+1]end dtb_d[#dtb_d]=""sfx(5)end function dtb_update()if #dtb_q>0 then if type(dtb_a[1])=='function' and not a_ran then a_ran=true dtb_a[1]() end if dtb_c==0 then dtb_c=1 end local z,x,q,c z=#dtb_d x=dtb_q[1]q=#dtb_d[z]c=q>=#x[dtb_c]if c and dtb_c>=#x then if btnp(4) then if dtb_f[1]~=0 then dtb_f[1]()end del(dtb_f,dtb_f[1])del(dtb_q,dtb_q[1])del(dtb_sp,dtb_sp[1])del(dtb_a,dtb_a[1]) a_ran=false _dtb_c()sfx(2)return end elseif dtb_c>0 then dtb_l-=1 if not c then if dtb_l<=0 then local v,h v=q+1 h=sub(x[dtb_c],v,v)dtb_l=1 if h~=" " then sfx(1)end if h=="." then dtb_l=6 end dtb_d[z]=dtb_d[z]..h end if btnp(4) then dtb_d[z]=x[dtb_c]end else if btnp(4) then _dtb_l()end end end end end function dtb_draw()if #dtb_q>0 then local z,o z=#dtb_d o=0 if dtb_c<z then o=z-dtb_c end rectfill(2,2,125,z*8,15) rectfill(3,7,20,24,12) rect(3,7,20,24,0) draw_mult(dtb_sp[1],4,(z*8)/4,true) if dtb_c>0 and #dtb_d[#dtb_d]==#dtb_q[1][dtb_c] then print("\x8e",118,120,1) end for i=1,z do print(dtb_d[i],23,i*8+27-(z+o)*8,2)end end end

--class definitions!--
--prototype 'actor'
actor={}
actor.sprite={{}}
actor.head_s={{}}
actor.anims={}
actor.x=0
actor.y=0
actor.flip=false
actor.nospc=true
actor.sat=0 --satisfaction. add modifiers from buffs, etc.
actor.maxhp=10
actor.hp=10
actor.rels={ald=0,minn=0,fer=0,tort=0}
actor.anim_queue={}
--actor.mems={} 'map' of memories; could be used for decision/reactions?
	
function actor:new(o)
	o = o or {}
	o = dcpy(self)
	setmetatable(o,self)
	self.__index=self
	return o
end

function actor:init(args,nospc)
	local args=split(args)
	sp_tab_init(self.sprite,
													args[1],
													args[2],
													args[3])
	self.x=args[4]
	self.y=args[5]
	self.nospc=nospc
	self.anims['none']=ani:new()

end

function actor:draw_still()
	draw_mult(self.sprite,
										self.x,self.y,
										self.nospc,
										self.flip)
end

function actor:anim_all()
	for name,anim in pairs(self.anims) do
		anim:play(0) --add nospc check in method?	
	end
end

function actor:draw()
	self:draw_still()
 for name,anim in pairs(self.anims) do
 	anim:update()
	end
	self:enq_draw()
end 	

function actor:anim_one(name,times)
	--print(name)
	self.anims[name]:play(times)
end

function actor:setflip(val)
	self.flip=val
	for name,anim in pairs(self.anims) do
		anim:hflip(val)
	end
end

function actor:translate(x,y)
	self.x+=x
	self.y+=y
	
	--translate all anis
	for name,anim in pairs(self.anims) do
		for idx,o_val in pairs(anim.x) do
			anim.x[idx] = o_val+x
		end
		for idx,o_val in pairs(anim.y) do
			anim.y[idx] = o_val+y
		end
	end
end 

function actor:say(words,sec_an,effect)

	local loops=#words\5
	if loops==0 then loops=1 end

	if(sec_an)~=nil then
		talk = function() self:anim_one('talk',loops)
		self:anim_one(sec_an,loops)
		end
	else
		talk = function() self:anim_one('talk',loops)
		end
	end
		
	dtb_disp(words,effect,self.head_s,talk)
end			

----gameplay fct.
function actor:react(r_table)
	local val=nil
 --satisfaction effects
	if r_table['sat']~=nil then
		self.sat+=r_table['sat']
		
		--logic for floater anim
		if r_table['sat']>=0 then
			val="_up"
		else
			val="_down"
		end
		self:enq_anim(self.anims['sat'..val])
	end
	
	--relationship effects
	for char,rel in pairs(self.rels) do
		if r_table[char]~=nil then
		self.rels[char]+=r_table[char]
		
			if r_table[char]>=0 then
				val="_up"
			else
				val="_down"
			end		
		self:enq_anim(self.anims[char..val])
		end
	end

	--anis
	if r_table['a']~=nil then
		if self.anims[r_table['a']]~=nil then
		 --do we have this anim?
			self:anim_one(r_table['a'],1)	
		end
	end	
			
end

function actor:enq_anim(anim)
	local l_an=dcpy(anim)
	pop = function()
		deli(self.anim_queue,1)
	end
	
	l_an:stop()
	l_an:reset()
	l_an.exit_f=pop
	add(self.anim_queue,l_an)
end

function actor:enq_draw()
	if #self.anim_queue>=1 then
		if not self.anim_queue[1].running then
			self.anim_queue[1]:play(1)
		else
			self.anim_queue[1]:update()
		end
	end
end
-->8
--ani class--
--ani proto class--
ani={}
ani.x={0,0}
ani.y={0,0}
ani.flip=false
ani.fl_offset=0
ani.tmr=1
ani.loop=0
ani.max_loops=0
ani.anim_seq={{{5}},{{5}}}
ani.seq_delay={0,0}
ani.cur_seq=1
ani.nospc=false
ani.running=false
ani.init_f=0
ani.exit_f=0
ani.dirs={x=0,y=1,anim_seq=2,seq_delay=3,fl_offset=4}

function ani:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index=self
	return o
end

function ani:load()
	 printh("loading animation...")
	for param,val in pairs(self.dirs) do
		--kludgy, but see if it works
		if param=="anim_seq" then
			self[param]=split_all(load_item(val),"|")
			self[param]=self[param][1]
		else
			self[param]=split_all(load_item(val))
		end
		printh(param.."= '"..load_item(val).."'")
	end
end

function ani:init(args)
	for key,val in pairs(args) do
		self[key]=val
	end
end

function ani:set(key,val)
	self[key]=val
end

function ani:start()
 self.running = true
 if self.init_f~=0 then
 	self:init_f()
 end
end

function ani:stop()
	self.running = false
	if self.exit_f~=0 then
		self:exit_f()
	end
end

function ani:reset()
	self.tmr = 1
	self.cur_seq = 1
	self.loops=0
end

function ani:play(num_lps)
	self:reset()
	self:start()
	self.max_loops=num_lps
end

--anims given an ani
--'object.' unless you're
--using an ani that
--translates a space-containing
--sprite, set no_space to 0.
function ani:spr_anim()
	self.tmr = self.tmr+1

	if self.tmr>=
		self.seq_delay[self.cur_seq]
		then

			--draw the moved next frame.
			--doesn't exclude frames
			--marked as 'space', 
			--so we can fit anis
			--in these empty spaces. 
			draw_mult(self.anim_seq[self.cur_seq],
							self.x[self.cur_seq],
							self.y[self.cur_seq],
							self.no_space,self.flip)
																
			self.tmr = 1 --reset timer
			self.cur_seq+=1 --incrment frame
			if self.cur_seq > #(self.anim_seq) then
					self.cur_seq = 1 --reset frame
					self.loops+=1 --increment num loops
			end								
	else

		draw_mult(self.anim_seq[self.cur_seq],
						self.x[self.cur_seq],
						self.y[self.cur_seq],
						self.no_space,self.flip)
	end
end	

		
--if loops<1, loop infinitely
function ani:update()

	if self.running then
		self:spr_anim()

	--prevent val from getting huge
		if self.loops>999 then 
			self.loops=0
		end
		
		if self.loops>=self.max_loops and self.max_loops>0 then

						self:stop()
						self:reset()

		end
	end
end
--end
function ani:hflip(val)
	local orig=self.flip
	self.flip=val
	
	local switch=1
	if orig==val then
		switch=0
	end
	if orig==false and val==true then
		switch=1
	end
	if orig==true and val==false then
		switch=-1
	end
	
	for idx,val in pairs(self.x) do
		self.x[idx]=val+switch*self.fl_offset
	end
end
-->8
--shared ani init--
--shared anis declared here,
--individual declared in actor's
--respective object. call these
--on ani objects to 
--'transform' them.

--these use a lot of tokens...
--it would be great to be able
--to specify a str or something
--to define all of these parameters
--intead of using tokens manually 
--assigning them. similar
--to what i'm doing with scenes/
--all that interpret goodness

--ellipsis ani
function dots_init(dots)

	--3957--
	dots.anim_seq = {{{5}},{{13}},{{29}},{{45}}}
	--dots.anim_seq=split_all("{{{5}},{{13}},{{29}},{{45}}}","|")
	dots.seq_delay = split("48,20,20,36")

end

--shock ani
function shock_init(shock)

	shock.anim_seq = {{{5}},{{14}},{{30}},{{46}}}
	shock.seq_delay = split("12,6,6,45")

end

--exclamation ani
function excl_init(excl)
	excl.anim_seq = {{{12}},{{28}},{{12}},{{28}}}
	excl.seq_delay = split("5,5,5,75")

end

--icon anim, used for 
--face ui icons and +/-
function float_icon_init(m,sp,up)
	local vl=nil
	if up then vl=103
	else vl=102
	end
	
	m.anim_seq={{{sp},{vl}},{{sp},{vl}},{{sp},{vl}},{{sp},{vl}}}
	m.seq_delay=split("5,5,5,20")

end

function all_float_init(ch,x,y)
		--alder icons--
	ch.anims['ald_up']=ani:new()
		local a_u=ch.anims['ald_up']
		float_icon_init(a_u,43,true)
		a_u.x={x,x,x,x}
		a_u.y={y,y+1,y,y-1} --bobs

--can definitely code this for fewer tokens		
	ch.anims['ald_down']=dcpy(a_u)
		float_icon_init(ch.anims['ald_down'],43,false)
	
	--torte icons--
	ch.anims['tort_up']=dcpy(a_u)
		float_icon_init(ch.anims['tort_up'],44,true)
	ch.anims['tort_down']=dcpy(a_u)
		float_icon_init(ch.anims['tort_down'],44,false)
	
	--feryn icons--
	ch.anims['fer_up']=dcpy(a_u)
		float_icon_init(ch.anims['fer_up'],60,true)
	ch.anims['fer_down']=dcpy(a_u)
		float_icon_init(ch.anims['fer_down'],60,false)
					
	--minnir icons--
	ch.anims['minn_up']=dcpy(a_u)
		float_icon_init(ch.anims['minn_up'],59,true)
	ch.anims['minn_down']=dcpy(a_u)
		float_icon_init(ch.anims['minn_down'],59,false)

	ch.anims['sat_up']=dcpy(a_u)
		float_icon_init(ch.anims['sat_up'],116,true)
	ch.anims['sat_down']=dcpy(a_u)
		float_icon_init(ch.anims['sat_down'],116,false)

end
-->8
--character inits--
--initialization functions:
--'transforms' an actor object
--into one of our beloved
--party members.
function ald_init(alder)
	alder:init("3,6,2,32,67",true)
	sp_tab_init(alder.head_s,3,2,2)
	alder.anims['blink']=ani:new()
	local bl = alder.anims['blink']

	--alder's blink
	bl.x=split("40,40") 
	bl.y=split("67,67")
	bl.fl_offset=-8
	bl.anim_seq = {{{4}},{{115}}}
	bl.seq_delay=split("110,8")

	--alder's ellipses
	alder.anims['dots']=ani:new()
	local dt = alder.anims['dots']
	dots_init(dt)
	dt.x=split("44,44,44,44")
	dt.y=split("66,66,66,66")
	dt.fl_ofset=-16

	--alder's talking ani	
	alder.anims['talk']=ani:new()
	local tlk = alder.anims['talk']
	shock_init(tlk)
	tlk.x=split("44,44,44,44")
	tlk.y=split("69,69,69,69")
	tlk.fl_offset=-16
	
	--alder's exclam ani
	alder.anims['excl']=ani:new()
	local ex = alder.anims['excl']
	excl_init(ex)
	ex.x=split("36,36,36,36")
	ex.y=split("56,56,56,56")
	ex.fl_offset=0

	--alder's breath ani
	alder.anims['twit']=ani:new()
	local tw = alder.anims['twit']
	tw.x=split("32,32,32,32")
	tw.y=split("83,83,83,83")
	tw.anim_seq={{{35}},{{99}},{{35}},{{99}}}
	tw.seq_delay=split("900,5,5,5")
	tw.fl_offset=8
	
	all_float_init(alder,4*8+4,(8*8)-7)
end

function min_init(minnir)
	minnir:init("0,7,3,8,53",true)
	--minnir's blink
	minnir.anims['blink']=ani:new()
	sp_tab_init(minnir.head_s,1,2,2)
	local bl = minnir.anims['blink']
	
	bl.x=split("16,16")
	bl.y=split("53,53")
--	{{{1}},{{112}}} : 7 tokens
	bl.anim_seq = {{{1}},{{112}}}
	bl.seq_delay=split("130,6")
	
--minnir's shock ani
	minnir.anims['shock']=ani:new()
	local shk = minnir.anims['shock']
	shock_init(shk)	
	shk.x=split("26,26,26,26")
	shk.y=split("53,53,53,53")
	shk.fl_offset=-20
	
--minnir's talking ani	
	minnir.anims['talk']=ani:new()
	local tlk = minnir.anims['talk']
	--!!!works now!!!---
	tlk.dirs={x=4,y=5,fl_offset=6,anim_seq=7,seq_delay=8}
	tlk:load()
	
--minnir's tail wag
	minnir.anims['wag']=ani:new()
	local wg=minnir.anims['wag']
	minnir.sprite[4][1]=5 --8 tokens!
--	minnir.disable(x,y) --5 tokens, but requires code
	minnir.sprite[5][1]=5
	minnir.sprite[6][1]=5
	minnir.sprite[7][1]=5
	
	m_wag_1={}
	m_wag_2={}
	m_wag_3={}
	sp_tab_init(m_wag_1,47,4,2)
		m_wag_1[1][1]=5
		m_wag_1[2][1]=5
		m_wag_1[3][1]=5
		m_wag_1[4][1]=5
	sp_tab_init(m_wag_2,76,4,2)
		m_wag_2[1][1]=5
	sp_tab_init(m_wag_3,78,4,2)
		m_wag_2[1][1]=5

	
	wg.x=split("0,0,0,0")
	wg.y=split("77,77,77,77")
	wg.fl_offset=24
	wg.anim_seq={m_wag_1,
														m_wag_3,
														m_wag_1,
														m_wag_2}

	wg.seq_delay=split("12,12,12,12")

--icons?

	all_float_init(minnir,2*8,6*8-5)
		
end

function tort_init(torte)

	torte:init("5,6,4,90,66",true)
	--torte's blink
		sp_tab_init(torte.head_s,6,2,2)
		torte.anims['blink']=ani:new()
		local t_blink = torte.anims['blink']
		t_blink.x=split("98,98")
		t_blink.y=split("66,66")
		t_blink.anim_seq = {{{6,7}},{{113,114}}}
		t_blink.seq_delay=split("165,9")

	--torte's tail wag
		t_wag_1={}
		t_wag_2={}
		t_wag_3={}
		sp_tab_init(t_wag_1,69,2,3)
		sp_tab_init(t_wag_2,100,2,3)
		sp_tab_init(t_wag_3,103,2,3)
		
		--replace identical sprites
		--to save space
		--ugly, lots of tokens. fix?
		--probably could make code...
		t_wag_2[1][1]=69
		t_wag_2[1][2]=70
		t_wag_2[1][3]=71
		t_wag_2[2][1]=85
		t_wag_3[1][1]=69
		t_wag_3[2][3]=87
		
		torte.anims['wag']=ani:new()
		tort_wag = torte.anims['wag']
		tort_wag.x=split("90,90,90,90")
		tort_wag.y=split("98,98,98,98")
		tort_wag.fl_offset=8
		tort_wag.anim_seq={t_wag_1,
																			 t_wag_2,
																			 t_wag_1,
																			 t_wag_3}
--
		tort_wag.seq_delay=split("7,7,7,7")
		
		--prevent still sprite from being
		--displayed underneath. ugly
		torte.sprite[5][1]=5
		torte.sprite[5][2]=5
		torte.sprite[5][3]=5
		torte.sprite[6][1]=5
		torte.sprite[6][2]=5
		torte.sprite[6][3]=5
		
		torte.anims['talk']=ani:new()
		local tlk = torte.anims['talk']
		tlk.x=split("98,98")
		tlk.y=split("74,74")
		tlk.fl_offset=8*1
		tlk.anim_seq={{{22}},{{91}}}
		tlk.seq_delay=split("4,7")
	
		--torte's ellipses
		torte.anims['dots']=ani:new()
		local dt = torte.anims['dots']
		dots_init(dt)
		dt.x=split("92,92,92,92")
		dt.y=split("66,66,66,66")
		dt.fl_offset=-16
		
	all_float_init(torte,(13*8)-3,7*8-2)	
end

function feryn_init(feryn)
	feryn:init("9,5,2,72,72",true)
	sp_tab_init(feryn.head_s,9,2,2)
	--feryn's blink
	feryn.anims['blink']=ani:new()
	local bl=feryn.anims['blink']
	bl.x=split("72,72")
	bl.y=split("72,72")
	bl.fl_offset=8
	bl.anim_seq={{{9}},{{11}}}
	bl.seq_delay={170,8}
	
	--feryn's talking ani	
	feryn.anims['talk']=ani:new()
	local tlk = feryn.anims['talk']
	tlk.x=split("72,72")
	tlk.y=split("80,80")
	tlk.fl_offset=8
	tlk.anim_seq={{{25}},{{27}}}
	tlk.seq_delay=split("4,7")
	
	--feryn's hand shift
	feryn.anims['shift']=ani:new()
	local sh = feryn.anims['shift']
	sh.x=split("72,72")
	sh.y=split("88,88")
	sh.anim_seq={{{41,42}},{{100,101}}}
	sh.seq_delay=split("1773,2010")
	
	feryn.sprite[3][1]=5
	feryn.sprite[3][2]=5

	all_float_init(feryn,9*8+3,8*8-3)
end
-->8
--dialogues and reactions--
reacts={}

--could make this a list of strings
--to be interpreted, but for now
--leaving effects on 'say' open-ended
reacts['unreas_react']=function()
		interpret("alder|react|{sat=-5,minn=-5};feryn|react|{sat=-3,minn=-3};torte|react|{sat=-5,minn=-5,a=dots}")
	end
	
reacts['f_joke_react']=function()
		interpret("alder|react|{sat=2};torte|react|{sat=5,fer=5};minnir|react|{sat=-2,a=shock};feryn|react|{sat=3,tort=3}")
	end --if there's only one option in table brackets, doesn't work...
	

-->8
--script and game state management--

--script class--
script={}
--script.parts="alder|say|sample;minnir|say|sample2"
script.parts={{}}
script.ran={{}}
script.brnc=split("a,b,c,d")
script.curpt="1_a"
script.cline=1
script.mlines={{}}


function script:new(o)
	o = o or {}
	o = dcpy(self)
	setmetatable(o,self)
	self.__index=self
	return o
end

--...do we even need separate new and init
--  functions???
-- okay but how are we gonna specify
-- branching scenes...? would require complicated
-- 'interpret'-ed syntax.
function script:initpt(part,str)
	--something about split_all breaks below...
	self.parts[part]=split(str,";")--this is just lines...
	self.ran[part]={}
	self.mlines[part] = #self.parts[part]
	for i=1,self.mlines[part] do
		self.ran[part][i]=false
	end
end

function script:start(part)
	self.curpt=part
end

function script:update()
	
	if #dtb_q==0 then --if dtb_q is empty, there are no dialogs left...!
		if not self.ran[self.curpt][self.cline] then
			interpret(self.parts[self.curpt][self.cline])
			self.ran[self.curpt][self.cline]=true
		end

	
		if self.cline > self.mlines[self.curpt] then
			self.cline=1
		else
			self.cline+=1
		end	
	
 end			
--end
--not done yet
end

---game states
menu_up=function()
	--todo:update for menu on top,
	--but draw all
	if #menu_stack~=0 then
		s_peek(menu_stack):update()
	end
	
end

dtb_up=function()
	dtb_update()
end

story_up=function()
	--story_update()
	scripts[curscript]:update()
end

--pause state--
pause_timer=1
last_state=3

function pause(frames)
	pause_timer=frames
	last_state=cur_state
	cur_state=4
end

pause_up=function()
	pause_timer-=1
	if pause_timer<1 then
		cur_state=last_state
	end
end
---

states={menu_up,dtb_up,story_up,pause_up}
cur_state=2
--^changing cur_state changes state

---scripts/scene list
scripts={}
curscript=nil

function start_sc(name,pt)
	if scripts[name]~=nil then
		scripts[name]:start(pt)
		curscript=name
		last_state=cur_state
		cur_state=3
	end
end

function scripts_init()
	scripts['test']=script:new()
	scripts['test']:initpt('1_a','minnir|say|testing...;alder|say|one two three;feryn|react|{sat=5,a=talk}')
end
-->8
--main game loops--
--main loops/routines and
--global actor list
m={}
a={}
f={}
t={}

--global bank table of contents
tocs={}
b_lens={}
		
actor_list={}	
function _init()
	--tars()
	palt(0, false) --black is drawn
	palt(14, true) --pink is trans.

	tocs[1],b_lens[1]=get_toc(1)	
	
	shock={}
	shock_init(shock)
	dots={}
	dots_init(dots)
	--initialize global anis--
	--initialize actors--
	actor_list['alder'] = actor:new()
		a=actor_list['alder']
		ald_init(a)
	actor_list['minnir'] = actor:new()
		m=actor_list['minnir']
		min_init(m)
	actor_list['torte'] = actor:new()
		t=actor_list['torte']
		tort_init(t)		
	actor_list['feryn'] = actor:new()
		f=actor_list['feryn']
		feryn_init(f)	
		
	--start their anis--

	a:anim_one('blink',0)	
	a:anim_one('twit',0)
	--a:anim_one('dots',0)
	
	m:anim_one('blink',0)
	m:anim_one('wag',0)
	
	t:anim_one('wag',0)
	t:anim_one('blink',0)
 
	f:anim_one('blink',0)
	f:anim_one('shift',0)


	dtb_init(4)
	--gradient_on()
	--color_draw()
	dialog_menu=menu:new()
--	dialog_menu:init("20,89,88,37","even rats,absolutely not,third option,fourth option,fifth option")
	dialog_menu:init("20,59,88,42",
					"even rats,absolutely not,three")
	--push(menu_stack,dialog_menu)

	dialog_menu.s_bhv=function()
		pop(menu_stack)
		pause(300)
		push(menu_stack,test_menu)
	end
	
	test_menu=menu:new()
	test_menu:init("5,5,118,42",
																"sample,semple,temple,tamper")

	test_menu.s_bhv=function()
		pop(menu_stack)
	end
	
	scripts_init()
--	push(menu_stack,test_menu)																
--	cur_state=1
--	pause(150)
--	
	start_sc('test','1_a')

end

flipval=false
counter = 0
pick_val=nil

function _update()
--
if(btnp(5)) then
		printh("button pressed")
		test=load_item(1)
		printh(test)
		printh("end of button test")
 	interpret(test)
end
	
	states[cur_state]()
	
	--printh(stat(1))
	dtb_update()
--	if pick_val==nil then 
--		pick_val=dialog_menu:update()
--	end
--	
end
	
function _draw()
	cls()

	map(0,0,0,0,16,16) --blue
	
--	foreach(actor_list, function(ac) ac:draw() end)
	a:draw()
	m:draw()
	f:draw()
	t:draw()
	
	dtb_draw()
	
	--draw all menus--
	if cur_state==1 then 
--		dialog_menu:draw()
		for idx,ui in pairs(menu_stack) do
			ui:draw()
		end
	end
	
	
	--choice_draw()	
end
-->8
--interpret--

--"alder|say|hi there-nil-nil;"
--converts a string into a full command
--used to exploit split and minimize
--token usage with story scripts
function interpret(script)

	local commands=split(script,';')

		for idx,cmd in pairs(commands) do
			local cmd_parts=split(cmd,"|")
			local actor=cmd_parts[1]
			local act=cmd_parts[2]
			local ac_s=actor_list[actor]
			local args=split_all(cmd_parts[3],">")
			local pass_args={ac_s}
			for idx,arg in pairs(args) do
				
					local add_val=dcpy(arg)
					--include :react() fcts
						if reacts[arg]~=nil then
							add_val=reacts[arg]
						end
						
						add(pass_args,add_val)

			end
		
		getmetatable(ac_s)[act](unpack(pass_args))

	end
end
							
-->8
--utility functions!--
--create a 2-dim table of an
--'even' sprite, ie all rows
--have the same # of columns.
--sprites must be contiguous.

function sp_tab_init(table,
									sprite_num,rows,cols)
			for i=1,rows do
				table[i]={}
				for j=1,cols do
					table[i][j]=sprite_num+
																	(16*(i-1))+
																	(j-1)
				end
			end
end

--dcpy utility, from 
--islet8 on stackoverflow
function dcpy(o, seen)
  seen = seen or {}
  if o == nil then return nil end
  if seen[o] then return seen[o] end

  local no
  if type(o) == 'table' then
    no = {}
    seen[o] = no

    for k, v in next, o, nil do
      no[dcpy(k, seen)] = dcpy(v, seen)
    end
    setmetatable(no, dcpy(getmetatable(o), seen))
  else -- number, string, boolean, etc
    no = o
  end
  return no
end

--a function to draw
--multi-sprite images, given
--a 2-dimensional table of 
--sprite numbers. unlike
--basic spr, can draw arbitrary
--sequences (good for swapping
--sprite components in/out)
--if 7th bit is set, it's in 
--the 'space' of a full sprite.
--use sprite 5 as 'true blank'
function draw_mult(s_tab,x,y,
																		nospc,fl)
	local rows=#s_tab
	--print(rows)
	--print(fl)
		for r = 1,rows do
		
			local cols=#(s_tab[r])
			for c = 1,cols do
			
				if fl then 
					s_val = s_tab[r][cols+1-c]
				else
					s_val = s_tab[r][c]
				end
				
				if fget(s_val,7) and nospc then
					s_val=5
				end
				spr(s_val,x+((c-1)*8),
														y+((r-1)*8),
														1,1,fl)
			end
		end
end	

--also gets tables, but only
--of one dimension. debug full v ^
--can do multiple depths now!!! up to three!
depth_delim={",","+","_"}
function split_all(str,delim,depth)
	local depth=depth or 1
	local spl=split(str,delim)

				for idx,arg in pairs(spl) do
			--handle types turned into strs.
			--source already does this with nums
					if arg=="nil" then
						spl[idx]=nil
					end
					if arg=="true" then
						spl[idx]=true
					end
					if arg=="false" then
						spl[idx]=false
					end
					--recursively get a table
			if sub(arg,1,1)=="{" then
						for i=1,#arg,1 do
--							printh(sub(arg,i,i))
							if sub(arg,i,i)=="}" then
								loc=i
							end
						end
						
					 
					
						spl[idx]=split_all(sub(arg,2,loc-1),depth_delim[depth],depth+1)
						
						local has_asst=false
						for i=1,#spl[idx] do 
							--support named key assignments
							
							local eq_tup=split_all(spl[idx][i],"=")
							if eq_tup!=nil then --if there are assignments
								if #eq_tup<2 then break end
								has_asst=true
								local name=eq_tup[1]
								local val=eq_tup[2]
								spl[idx][name]=val
							else break 				
							end
						
						--clean up int indexes... but does so indiscriminately
						--maybe consider per idx checking, for mixed named key asst and integer keys?
						if has_asst then 
							for i=1,#spl[idx] do
								spl[idx][i]=nil
							end
						end
					end
				end
			end
	return spl
end


--stack fcts
function push(stk,item)
	add(stk,item)
end

function top(stk)
	local tp=#stk
	return tp
end

function s_peek(stk)
	local t=top(stk)
	return stk[t]
end

function pop(stk)
	local t=top(stk)
	local popped=dcpy(stk[t])
	deli(stk,t)
	return popped
end

-->8
--cart-loading code--

--convert a string into a series of bytes
--can be used with interpret to
--load script commands from memory/another cart!
function pokestr(str,addr,term)
	local t = term or "`"
	local len=#str
	for i=1,len do
		poke(addr+(i-1),ord(str,i))
	end
	--null terminator
	poke(addr+len,ord(t))
	--assuming contiguous memory,
	--return next free address
	return len,addr+len+1
end

function peekstr(st_addr,term)
	local t = term or "`"
	local str=""
	local byte=0
	local curchar=chr(@(st_addr+byte))

	while (curchar!=t and byte<max_size) do
		str=str..curchar
		byte+=1
		curchar=chr(@(st_addr+byte))
	end
	--strings end up loading as 
	--"str|str|strsargs ". +2 to skip space/delim
	return str,byte+2
end

function peekints(st_addr,end_addr)
	local tbl={}
	for i=st_addr,end_addr,2 do 
		cur2bytes=%i
		add(tbl,cur2bytes)
	end
	--save memory--
	--toc won't ever contain zeros 
	for j=1,#tbl do
		if tbl[j]==0 then tbl[j]=nil end
	end
	
	return tbl
end

free_start=0x4300
free_end=0x47a9
cmd_mem_start=0x47aa
cmd_mem_end=0x5dff
cmd_win_len=cmd_mem_end-cmd_mem_start

sect_size=5717
max_size=5000
max_sect=2
cur_offset=0
cur_sect=0
cur_cart="d_bank_1.p8"

--bank constants
res_addr=0x0
res_end=0x0+171
idx_addr=res_end+1
idx_end=idx_addr+500
bank_addr=idx_end+1
bank_end=0x42ff

function get_toc(cartnum)
	--local toc={}
	reload(cmd_mem_start,idx_addr,idx_end-idx_addr,"d_bank_"..cartnum..".p8")
	--get table from cart
	local toc = peekints(cmd_mem_start,cmd_mem_start+(idx_end-idx_addr))
	
	local lens={}
	for i=1,#toc do 
		nexta=toc[i+1] or 5000
		add(lens,nexta-toc[i])
	end
	
	return toc,lens
end

--requires global tocs and lens
function load_item(idx,cart)
	--clean up
	memset(cmd_mem_start,nil,5000)
	
	cart=cart or 1
	local addr=tocs[cart][idx]
	local len=b_lens[cart][idx]
	
	reload(cmd_mem_start,addr,len-1,"d_bank_"..cart..".p8")
	
	local item=peekstr(cmd_mem_start)
	return item
end
__gfx__
eeeffeeeeeeeeeeeeeffeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeffffffeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddeeeeeeeeeeeeeeeeeeecccccccc
eeeefffeeeeeeeeefffeeeeeeeeeee79aaaeeeeeeeeeeeeeeeeeeee3333effffeefffeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddeeeeeeeeeeeeeeeeeeecccccccc
eeeeffffff944449ffeeeeeeeeeee9aaaa8eeeeeeeeeeeeeee5553333333fffeeeefffffeeeee33313eeeeeeeeeee333eeeddeeeeeeeeeeeeeeeeeeecccccccc
eeeeeeffff9444445eeeeeeeeeeeeaaa998eeeeeeeeeeeeeeee333555533fffeeeeffffeeeee333333eeeeeeeeee3333eeeddeeee7eeeeeee7eeeeeecccccccc
eeeeee55f944555455eeeeeeeeee97a8808eeeeeeeeeeeeeeee093309333ffeeeeeffeeeeee133ddd33eeeeeeee133ddeeeddeeeeeeeeeeee77eeeeecccccccc
eeeee555544430444eeeeeeeeeeeeaa88888eeeeeeeeeeeeee533333333fffeeeeffeeeeeee333d3d33eeeeeeee333d3eeeeeeeeeeeeeeeee7eeeeeecccccccc
eeeeeee444444444050eeeeeeeee9a88888eeeeeeeeeeeeeee353333333ff3eeeffeeeeeee33d0d0dd33eeeeee33ddddeeeddeeeeeeeeeeeeeeeeeeecccccccc
eeeeeee444994444555eeeeeeeee7488888eeeeeeeeeeeeee4333333533ff44efffeeeeeee336ddd6d33eeeeee336dddeeeddeeeeeeeeeeeeeeeeeee55555555
eeeeeed449994440000eeeeeeeeeee888eeeeeeeeeeeeeeee435555588ff344fffeeeeeeeee3ddd0dd3eeeeeeee3dd00eee77eeeeeeeeeeeeeeeeeee55555555
eeeeeedd44994444444eeeeeeeee228882222eeeeeeeeee44003153383f334fffeeeeeeeee33dd0dd331eeeeee33dd0deee77eeeeeeeeeeeeee7eeeecccccccc
eeeeedddd449445e999eeeeeee222228822222eeeeeeee40000511333ff00fff44eeeeeeee133ddd5331eeeeee133dddeee77eeeeeeeeeeeee7eeeeecccccccc
ee666666dd44449ee99eeeeeee22227777222eeeeeeee440055511222f2fff4444eeeeeeeee33355553eeeeeeee33355eee77eeee7e7eeeee7eeeeeecccccccc
e66666666d44499666eeeeeeeee2227777722eeeeeee44333355ff33ff3ff0044444eeeeee36665226331eeeee366652eee77eeeeeeeeeeee7777eeecccccccc
e667666666dddd9d666eeeeeeee2227777722eeeeee443333355ff33f3ff000044444eeeee66222226663eeeee662222eeeeeeeeeeeeeeeee7eeeeeecccccccc
66676666665555d5556eeeeeeee2222777722eeeeee433333355ffaaf3f03330044444eee666222222666eeee6662222eee77eeeeeeeeeeeee7eeeeecccccccc
66766666665555555566eeeeeee2222777222eeeeee333333a5afffffff33333044444ee66662222226666ee66662222eee77eeeeeeeeeeeeeeeeeeecccccccc
66666666655555555556eeeeeee288d222222eeeee33333aaaaaf88888f33333344444ee6661e2222236666eeeaaaaaee333333eeeeeeeeeeeee7eeecccccccc
66666666655555555556eeeeeee288d222222eeeee3333aaaaa8888888833333344444eee663edddd73e666eea888aa733333333eeeeeeeeeee7eeeecccccccc
66666666555555555556eeeeeee2222222d82eeee33333aaaa88888888833333384444eee666d6dd777e66eeaa98899a35533553eeeeeeeeee7eeeeecccccccc
e6666665555555555556eeeeeee2222777752eeeeb3333aaaa88888888833333384444eeee6dd667777d66eeaa08808a33033033e7e7e7eee7eeeeeecccccccc
e6666665555555555554eeeeeee2227777752eeebb3333aaaaf3333333333333384444eeeeedd6677ddd6eee7888888a33333333eeeeeeeee77777eecccccccc
e46666655555555555544eeeeee2224445552eeeeb33333aaa4433333333333bb84444eeeee666677dddeeee9888888485333358eeeeeeeee7eeeeeecccccccc
e44466455555555555544eeeeee2244445552eeee333333aaf333333333333bb884474eeeee666677777eeeee980089733533533eeeeeeeeee7eeeeecccccccc
e44444455555555555544eeeeee2444445552eeeee3333333f44433333333bbb044474eeeee666677777eeeeee8888eeee3553eeeeeeeeeeeee7eeeecccccccc
444444455555555555544eeeeee2444445552eeeee43333333faaaa333333550444474eeeee666677777eeeeffeeeeffe3313333eeeeeeeeeeeeeeeeeeeee7ee
4444444655555555555444eeeee2444445552eeeee440333333aaaaaaaa5555044474eeeeee666677777eeee5f4444f533dddd31eeee77eeeeeeeeeeeee777ee
444444466555555555d444eeeee2244445552eeeee4400a3344aaaaaaa55555044474eeeeeee66667777eeee455445543d3dd3d3eeee7e7eeee77777eee7eeee
e4444444665555555ddd4444eee22444455522eeee4440a343aaaaaaaa55555044744eeeeeee66667777eeeee404404e3d0dd0d3eeee7eeeeee7eee7eee7e7e7
e554444466666666dddd4444eee22444455552eeee4445aa4faaaaaaa555550444744eeeeeee66667777eeeee444444e36dddd63eeee7eeeeee7eee7eee7ee7e
e4544444466666666dddd444ee222444455552eeee4455afffaaaaaaa33550044444eeeeeeee66667777eeeee505505e1d0dd0d3e7777eeeeee7e777eee7e7e7
44454444466666666dddd444ee222244455552eeee445fffffaaaa33333550044444eeeeeeee66667777eeeee555555e33d00d33e777eeee7777e777777eeeee
44454444466666666dddddeeee222244455522eeeee45fffffaa333333330004444eeeeeeeeee6666777eeeee400004e31dddd13eeeeeeee777eeeee777eeeee
44454444446666666dddddeeee222244455522eeeee555fffff3333333330044444eeeeeeeeeeee66777eeee49994440000eeeee44444445eeeeeeee44444445
444e44444466666dddddddeeee2224444555222eeee55555ff5333333333004444eeeeeeeeeeeee66777eeee44994444004eeeee44444446eeeeeeee44444446
44ee44444466666dddddddeee222244445555222eee55555555333333333044444eeeeeeeeeeeee11222eeeed4494454444eeeee44444446eeeeeeee44444446
444ee4444666666dddddddeee22224444e555222eee5555555513333333304444eeeeeeeeeeeee0005555eeedd44449e999eeeeee4444444eeeeeeeee4444444
e444eee66666666dddddddeee22ee4444e5555eeeee555555511333333330444eeeeeeeeeeeee000055555ee6d444996699eeeeeee544444eeeeeeeeee544444
ee444ee66666666dddddddeeeeeeee44eee000eeeeee55555511bb3333334444eeeeeeeeeeee0000055555ee66dddd9d666eeeeeee544444eeeeeeeee4544444
eee44ee666666666ddddddeeeeeeee00eeeddddeeeee55555511bbbb3333444eeeeeeeeeeeeeeeeeeeeeeeee665555d5556eeeeeee454444eeeeeeee44454444
eee44eee6666666ddddddeeeeeeeeddddeedddddeeee555555111bbb33334eeeeeeeeeeeeeeeeeeeeeeeeeee665555555566eeeee4454444eeeeeeee44454444
eee44ee66666555ddddddeeeeeeeeddddeedddddeeee555555511bbb3333eeeeeeeeeeeeeeeeeeeeeeeeeeeee4355555eeeeeeeee4445444eeeeeee444454444
ee44ee666666555ddddddeeeeeeeedddeeeeeeeeeeeee555555111b333333eeeeeeeeeeeeeeeeeeeeeeeeeee40031555eeeeeeeee4445444eeeeeee444454444
ee44ee666665555ddddddeeeeeeedddeeeeeeeeeeeeee555555e113333333eeeeeeeeeeeeeeeeeeeeeeeeeee00051133eeeeeeeee4445444eeeeeee444ee4444
e44ee666666555ddddddeeeeeeeeeeeeeeeeeeeeeeee5555555e113333333eeeeeeeeeeeeeeeeeeeeeeeeeee05551122eeeeeeeee4445444eeeeeee444eee444
44eee666666555ddddddeeeeeeeeeeeeeeeeeeeeeee555555555e13333333eeeeeeeeeeeeeeeeeeeeeeeeeee3355ff33eeeeeeeee444eee6eeeeeee444eeeee6
4eeee66666555dddddddeeeeeeeeeeeeeeeeeeeeee5555555555333333333eeeeeeeeeeeeeeeeeeeeeeeeeee3355ff33eeeeeeeee444eee6eeeeeee444eeeee6
4eeee66666555ddddddeeeeeeeeeeeeeeeeeeeeee555555555533433433333eeeeeeeeeeeeeeeeeeeeeeeeee3355ffaaeeeeeeeeee44eee6eeeeeeee44eeeee6
44eee6666655dddddddeeeeeeeeeeeeeeeeeeeeee555555555534434433333eeeeeeeeeeeeeeeeeeeeeeeeee3a5affffeeeeeeeeee444eeeeeeeeeee44eeeeee
e4e9e666655eddddddeeeeeeeee228d26661e222223e666eeeeeeeeeeeeeeeeefff3333333330044eeeeeeeeeeeeeeeeeeeeeeeeeee444e6eeeeeeee444eeee6
e999e666655eedddddeeeeeeeee228d2e663edddd73666eeee8888eeeeebbeeeff53333333330044eeeeeeeeeeeeeeeeeeeeeeeeeeee4466eeeeeeeee44eee66
e999ee66666eeddddeeeeeeeeee22222e66636dd777d66eeeeeeeeeeeebbbbee5553333333330444eeeeeeeeeeeeeeeeeeeeeeeeeeeee466eeeeeeeee44eee66
eeeeee64444eed444eeeeeeeeee22227ee6dd6677ddd6eeeeeeeeeeeeeebbeee5551333333330444eeeeeeeeeeeeeeeeeeeeeeeeeeeee666eeeeeeeeee4ee666
eeeeee440000e4555eeeeeeeeee22277ee6dd6677dddeeeeeeeeeeeeeeeeeeee5511333333330444eeeeeeeeeeeeeeeeeeeeeeeeeeeee666eeeeeeeeee4ee666
eeeeee000070e555555eeeeeeee22244eeedd6677777eeeeeeeeeeeeeeeeeeee5511bb3333334444eeeeeeeeeeeeeeeeeeeeeeeeeeeee666eee9eeeee44ee666
eeeee000000005555555eeeeeee22444eee666677777eeeeeeeeeeeeeeeeeeee5511bbbb3333444eeeeeeeeeeeeeeeeeeeeeeeeeeeeee666eee99eeee4eee666
eeeee0000000005555555eeeeee24444eee666677777eeeeeeeeeeeeeeeeeeee5511ebbb33334eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666eee99ee444eee666
eeeeeeeeeeeeeeeeeeefffffeeeeeeeeeddeedde55511bbb333311eeeeee55555551ebbbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666eee99444eeeee666
eeeeeeeeeeeeeee3333effffaaaeeeeedddddddd555e11b33333311eee111555555eeeb3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee666eeeeeeeeeeeee666
ff944449ee5553333333fffeaa8eeeeedddddd7d555eee333333311eeee11555555eee33eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee66eeeeeeeeeeeeee66
ff944444eee333555533fffe998eeeeeddddd7dd555eee3333333e11eeee5555555eee33eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee64eeeeeeeeeeeeee64
f9445554eee333333333ffee888eeeeed1dddddd555eee3333333eeeeee555555555ee33eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44eeeeeeeeeeeeee44
54444444ee533333333fffee8888eeeeed1dddde5555333333333eeeee55555555553333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00eeeeeeeeeeeeee00
44444444ee353333333ff3ee888eeeeeeed1ddee55533433433333eee555555555533433eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000eeeeeeeeeeeee000
44994444e4333333533ff44e888eeeeeeeeddeee55534434433333eee555555555534434eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000eeeeeeeeeeeee000
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccffcccccccccccccffcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccfffcccccccccfffccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccffffff944449ffcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccffff9444445ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccc55f944555455cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccc555544430444ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccc444444444050ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccc444994444555ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccd449994440000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccdd44994444444ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccdddd449445c999ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc666666dd44449cc99ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccc66666666d44499666cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccc667666666dddd9d666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccffffffccccccccccccc
cccccccc66676666665555d5556cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3333cffffccfffccccccccc
cccccccc66766666665555555566cccccccccc79aaaccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5553333333fffccccfffffcccccc
cccccccc66666666655555555556ccccccccc9aaaa8cc7c7ccccccccccccccccccccccccccccccccccccccccccccccccccccc333555533fffccccffffccccccc
cccccccc66666666655555555556cccccccccaaa998cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc093309333ffcccccffccccccccc
cccccccc66666666555555555556cccccccc97a8808ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc533333333fffccccffcccccccccc
ccccccccc6666665555555555556cccccccccaa88888cccccccccccccccccccccccccccccccccccccccccccccccccccccccc353333333ff3cccffccccccccccc
ccccccccc6666665555555555554cccccccc9a88888cccccccccccccccccccccccccccccccccccccccccccccccccccccccc4333333533ff44cfffccccccccccc
ccccccccc46666655555555555544ccccccc7488888cccccccccccccccccccccccccccccc33313ccccccccccccccccccccc435555588ff344fffcccccccccccc
ccccccccc44466455555555555544ccccccccc888ccccccccccccccccccccccccccccccc333333ccccccccccccccccccc44003153383f334fffccccccccccccc
ccccccccc44444455555555555544ccccccc228882222cccccccccccccccccccccccccc133ddd33ccccccccccccccccc40000511333ff00fff44cccccccccccc
cccccccc444444455555555555544ccccc222228822222ccccccccccccccccccccccccc333d3d33cccccccccccccccc440055511222f2fff4444cccccccccccc
cccccccc4444444655555555555444cccc22227777222ccccccccccccccccccccccccc33d0d0dd33cccccccccccccc44333355ff33ff3ff0044444cccccccccc
cccccccc444444466555555555d444ccccc2227777722ccccccccccccccccccccccccc336ddd6d33ccccccccccccc443333355ff33f3ff000044444ccccccccc
ccccccccc4444444665555555ddd4444ccc2227777722cccccccccccccccccccccccccc3ddd0dd3cccccccc6ccccc433333355ffaaf3f03330044444cccccccc
cccccccccc54444466666666dddd4444ccc2222777722ccccccccccccccccccccccccc33dd0dd331ccccc46cccccc333333a5afffffff33333044444cccccccc
ccccccccc4544444466666666dddd444ccc2222777222ccccccccccccccccccccccccc133ddd5331cccc444ccccc33333aaaaaf88888f33333344444cccccccc
cccccccc44454444466666666dddd444ccc288d222222cccccccccccccccccccccccccc33355553ccccc787ccccc3333aaaaa8888888833333344444cccccccc
cccccccc44454444466666666dddddccccc288d222222ccccccccccccccccccccccccc33665226331ccc777cccc33333aaaa88888888833333384444cccccccc
cccccccc44cc4444446666666dddddccccc2222222d82ccccccccccccccccccccccccc66222226663cccdddccccb3333aaaa88888888833333384444cccccccc
cccccccc44cc44444466666dddddddccccc2222777752ccccccccccccccccccccccc6666222222663666ddccccbb3333aaaaf3333333333333384444cccccccc
cccccccc44cc44444466666dddddddccccc2227777752cccccccccccccccccccccc66666222222666666cccccccb33333aaa4433333333333bb84444cccccccc
cccccccc44ccc4444666666dddddddccccc2224445552ccccccccccccccccccddd666632c222223666ccccccccc333333aaf333333333333bb884474cccccccc
ccccccccc4ccccc66666666dddddddccccc2244445552ccccccccccccccccc7ddd76cc33cdddd73ccccccccccccc3333333f44433333333bbb044474cccccccc
ccccccccc44cccc66666666dddddddccccc2444445552ccccccccccccccccc7ddd7ccc1c6ddd777ccccccccccccc43333333faaaa333333550444474cccccccc
cccccccccc4cccc666666666ddddddccccc2444445552cccccccccccccccccc777cccccc66dd777ccccccccccccc440333333aaaaaaaa5555044474ccccccccc
cccccccccc4ccccc6666666ddddddcccccc2444445552ccccccccccccccccccc4ccccccc66677777cccccccccccc4400a3344aaaaaaa55555044474ccccccccc
cccccccccc4cccc66666555ddddddcccccc2244445552ccccccccccccccccccc4ccccccc66677777cccccccccccc4440a343aaaaaaaa55555044744ccccccccc
cccccccccc4ccc666666555ddddddcccccc22444455522cccccccccccccccccc4cccccc666677777cccccccccccc4445aa4faaaaaaa555550444744ccccccccc
cccccccccc4ccc666665555ddddddcccccc22444455552cccccccccccccccccc4cccccc666677777cccccccccccc4455afffaaaaaaa33550044444cccccccccc
ccccccccc44cc666666555ddddddcccccc222444455552cccccccccccccccccc4cccccc666677777cccccccccccc445fffffaaaa33333550044444cccccccccc
cccccccc44ccc666666555ddddddcccccc222244455552cccccccccccccccccc4cccccc666677777ccccccccccccc45fffffaa333333330004444ccccccccccc
cccccccc4cccc66666555dddddddcccccc222244455522cccccccccccccccccc4ccccccc66667777ccccccccccccc555fffff3333333330044444ccccccccccc
cccccccc4cccc66666555ddddddccccccc222244455522cccccccccccccccccc4ccccccc66667777ccccccccccccc55555ff5333333333004444cccccccccccc
cccccccc44ccc6666655dddddddccccccc2224444555222ccccccccccccccccc4ccccccc66667777ccccccccccccc55555555333333333044444cccccccccccc
ccccccccc4c9c666655cddddddccccccc222244445555222ccccccccccccc6c44ccccccc66667777ccccccccccccc5555555513333333304444ccccccccccccc
ccccccccc999c666655ccdddddccccccc22224444c555222ccccccccccccc664cc6ccccc66667777cccccccccccccc55555511333333330444cccccccccccccc
ccccccccc999cc66666ccddddcccccccc22cc4444c5555cccccccccccccc6666666cccccc6666777cccccccccccccc55555511bb3333334444cccccccccccccc
555555555555556444455d44455555555555554455500055555555555555666666655555555667775555555555555555555511bbbb3333444555555555555555
cccccccccccccc440000c4555ccccccccccccc00cccddddccccccccccccc676666ccccccccc66777ccccccccccccccc55555111bbb33334ccccccccccccccccc
cccccccccccccc000070c555555ccccccccccddddccdddddcccccccccccc667666ccccccccc11222ccccccccccccccc55555511bbb333311cccccccccccccccc
ccccccccccccc000000005555555cccccccccddddccdddddccccccccccccc6666ccccccccc0005555cccccccccccccc555555c11b33333311ccccccccccccccc
ccccccccccccc0000000005555555ccccccccdddccccccccccccccccccccc666ccccccccc000055555cccccccccccc5555555ccc333333311ccccccccccccccc
ccccccccccccccccccccccccccccccccccccdddcccccccccccccccccccccc66ccccccccc0000055555ccccccccccc55555555ccc3333333c11cccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5555555555cc3333333ccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5555555555333333333ccccccccccccccccc
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555334334333335555555555555555
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc55534434433333cccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000000080000080000000000000000000000000000000000000000000000000000000000000000000000000
0000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000
__map__
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2fffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f00ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f00ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1fffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1fffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0fffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000800001a027150271602714027110271300012000170001c0001f0002300025000280002a0002b00026000200001b00017000170001b000220002b0003100033000310001f3002030020300327003370024700
000400002d7402c7402a7402a7402b7302570020700247001f7001d700187000f70015700197001d7002070014700177001a700267003270032700307002b7002e7002d7002a700297002f7002f7002500020000
01080000135501155010550115501255000300003001d650006001b65000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000900000952003513000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
00100000065200e520115100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
