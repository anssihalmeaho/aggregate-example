
ns main

main = proc()
	import chatstore
	import stdpp
	import sure

	# make aggregate object
	store = call(chatstore.new)

	# assign names for methods of aggregate object
	add-group = get(store 'add-group')
	add-user = get(store 'add-user')
	add-user-to-group = get(store 'add-user-to-group')
	get-groups = get(store 'get-groups')
	get-users = get(store 'get-users')
	get-users-of-group = get(store 'get-users-of-group')
	get-groups-of-user = get(store 'get-groups-of-user')
	content = get(store 'content')

	# add some groups/topics
	call(sure.ok call(add-group 'Movie Fans'))
	call(sure.ok call(add-group 'Old Music'))
	call(sure.ok call(add-group 'Comics'))

	# add some users
	call(sure.ok call(add-user 'Bob'))
	call(sure.ok call(add-user 'Alice'))
	call(sure.ok call(add-user 'Jim'))

	# add users to groups
	call(sure.ok call(add-user-to-group 'Bob' 'Movie Fans'))
	call(sure.ok call(add-user-to-group 'Alice' 'Movie Fans'))
	call(sure.ok call(add-user-to-group 'Alice' 'Old Music'))
	call(sure.ok call(add-user-to-group 'Alice' 'Old Music'))
	call(sure.ok call(add-user-to-group 'Jim' 'Old Music'))
	call(sure.ok call(add-user-to-group 'Jim' 'Comics'))
	call(sure.ok call(add-user-to-group 'Bob' 'Comics'))

	# print users, groups, users by group and groups by user
	call(stdpp.pform list(
		'\nGroups: '
		call(get-groups)
		'\nUsers: '
		call(get-users)
		'\nUsers by Group: '
		call(get-users-of-group)
		'\nGroups by User: '
		call(get-groups-of-user)
	))
end

endns

