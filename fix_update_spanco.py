import os

stages = [
    'suspecting',
    'prospecting',
    'approaching',
    'negotiating',
    'closure',
    'order'
]

base_dir = '/Users/tchitchi/Desktop/crm app/crm_app_smmart/lib/features/spanco'

for stage in stages:
    c_path = f'{base_dir}/{stage}/controller/{stage}_controller.dart'
    if os.path.exists(c_path):
        with open(c_path, 'r') as f:
            data = f.read()
            
        print_stmt = "\n    print('Update Body: $body');\n    ResponseModel responseModel = await repo.updateData(body);"
        data = data.replace('ResponseModel responseModel = await repo.updateData(body);', print_stmt)
        
        with open(c_path, 'w') as f:
            f.write(data)

print("Added prints.")
