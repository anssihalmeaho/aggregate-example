
ns chatstore

new = proc()
	import stdvar
	import lens
	import stdfu

	store = call(stdvar.new map(
		'users'  list()
		'groups' list()
		'groups-by-user' map()
		'users-by-group' map()
	))

	content = proc()
		call(stdvar.value store)
	end

	add-group = proc(group-name)
		ok err _ result = call(stdvar.change-v2 store func(old-store)
			old-groups = get(old-store 'groups')
			if(in(old-groups group-name)
				list(old-store list(false 'group already exists'))
				call(func()
					new-groups = append(old-groups group-name)
					new-store = call(stdfu.chain old-store list(
						func(v)
							call(lens.set-to list('groups') v new-groups)
						end
						func(v)
							call(lens.set-to list('users-by-group' group-name) v list())
						end
					))
					list(new-store list(true ''))
				end)
			)
		end):
		if(ok
			result
			list(false err)
		)
	end

	add-user = proc(username)
		ok err _ result = call(stdvar.change-v2 store func(old-store)
			old-users = get(old-store 'users')
			if(in(old-users username)
				list(old-store list(false 'user already exists'))
				call(func()
					new-users = append(old-users username)
					new-store = call(stdfu.chain old-store list(
						func(v)
							call(lens.set-to list('users') v new-users)
						end
						func(v)
							call(lens.set-to list('groups-by-user' username) v list())
						end
					))
					list(new-store list(true ''))
				end)
			)
		end):
		if(ok
			result
			list(false err)
		)
	end

	add-user-to-group = proc(username group-name)
		ok err _ result = call(stdvar.change-v2 store func(old-store)
			old-groups = get(old-store 'groups')
			old-users = get(old-store 'users')
			groups-by-user = get(old-store 'groups-by-user')
			users-by-group = get(old-store 'users-by-group')

			cond(
				not(in(old-groups group-name))
				list(old-store list(false 'group not found'))

				not(in(old-users username))
				list(old-store list(false 'user not found'))

				call(func()
					new-store = call(stdfu.chain old-store list(
						func(v)
							path = list('groups-by-user' username)
							_ old-list = call(lens.get-from path v):
							new-list = if(in(old-list group-name)
								old-list
								append(old-list group-name)
							)
							call(lens.set-to path v new-list)
						end
						func(v)
							path = list('users-by-group' group-name)
							_ old-list = call(lens.get-from path v):
							new-list = if(in(old-list username)
								old-list
								append(old-list username)
							)
							call(lens.set-to path v new-list)
						end
					))
					list(new-store list(true ''))
				end)
			)
		end):
		if(ok
			result
			list(false err)
		)
	end

	get-groups = proc()
		get(call(stdvar.value store) 'groups')
	end

	get-users = proc()
		get(call(stdvar.value store) 'users')
	end

	get-users-of-group = proc()
		get(call(stdvar.value store) 'users-by-group')
	end

	get-groups-of-user = proc()
		get(call(stdvar.value store) 'groups-by-user')
	end

	map(
		'add-group'          add-group
		'add-user'           add-user
		'add-user-to-group'  add-user-to-group

		'get-groups'         get-groups
		'get-users'          get-users
		'get-users-of-group' get-users-of-group
		'get-groups-of-user' get-groups-of-user

		'content' content
	)
end

test = proc()
	import stddbc
	import sure

	store = call(new)

	add-group = get(store 'add-group')
	add-user = get(store 'add-user')
	add-user-to-group = get(store 'add-user-to-group')
	get-groups = get(store 'get-groups')
	get-users = get(store 'get-users')
	get-users-of-group = get(store 'get-users-of-group')
	get-groups-of-user = get(store 'get-groups-of-user')
	content = get(store 'content')

	assure-error = proc(value assumed-err)
		ok err = value:
		call(stddbc.assert not(ok) 'assuming ok being false')
		call(stddbc.assert eq(err assumed-err) sprintf('unexpected error: %v' assumed-err))
	end

	call(sure.ok call(add-group 'g1'))
	call(sure.ok call(add-group 'g2'))
	call(sure.ok call(add-group 'g3'))
	call(assure-error call(add-group 'g1') 'group already exists')

	call(sure.ok call(add-user 'u1'))
	call(sure.ok call(add-user 'u2'))
	call(sure.ok call(add-user 'u3'))
	call(assure-error call(add-user 'u3') 'user already exists')

	call(sure.ok call(add-user-to-group 'u1' 'g1'))
	call(sure.ok call(add-user-to-group 'u1' 'g2'))
	call(sure.ok call(add-user-to-group 'u2' 'g1'))
	call(sure.ok call(add-user-to-group 'u2' 'g3'))
	call(sure.ok call(add-user-to-group 'u3' 'g2'))
	call(sure.ok call(add-user-to-group 'u3' 'g3'))

	# non existing users or groups
	call(assure-error call(add-user-to-group 'ux' 'g1') 'user not found')
	call(assure-error call(add-user-to-group 'u1' 'gx') 'group not found')

	# adding same twice (is not error but doesn't add duplicate)
	call(sure.ok call(add-user-to-group 'u1' 'g1'))

	verify-data = proc(data assumed-data)
		call(stddbc.assert eq(data assumed-data) sprintf('unexpected data: %v' assumed-data))
	end

	call(verify-data call(get-groups) list('g1' 'g2' 'g3'))
	call(verify-data call(get-users) list('u1' 'u2' 'u3'))
	call(verify-data call(get-users-of-group)
		map(
			'g1' list('u1' 'u2')
			'g2' list('u1' 'u3')
			'g3' list('u2' 'u3')
		)
	)
	call(verify-data call(get-groups-of-user)
		map(
			'u1' list('g1' 'g2')
			'u2' list('g1' 'g3')
			'u3' list('g2' 'g3')
		)
	)

	'PASSED'
end

endns

