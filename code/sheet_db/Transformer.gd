extends Node 

const ARRAY_KEYS = ['REQUIRED']

# Transforms nested csv array to node dictionary 
func transform(data):
	var result = {}
	
	if len(data) > 1:
		result['version'] = data[0][0]
		var keys = data[0].slice(1)
		
		# Initialize the dictionary
		# The ID is the key of the node
		for i in range(1, len(data)):
			var id = data[i][1] 
			if not result.has(id):
				result[id] = {}

		# Extract data into each node
		for i in range(1, len(keys) + 1):
			var key = keys[i - 1]
			for j in range(1, len(data)):
				if i < len(data[j]):
					var id = data[j][1]
					if key in ARRAY_KEYS:
						result[id][key] = data[j][i].split(',')
					else:
						result[id][key] = data[j][i] or ''
				else:
					push_warning("Index out of bounds for row %d, column %d" % [j, i])
				
	return result
