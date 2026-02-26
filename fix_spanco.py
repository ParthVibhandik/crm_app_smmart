import os

stages = [
    ('prospecting', 'Prospecting'),
    ('approaching', 'Approaching'),
    ('negotiating', 'Negotiating'),
    ('closure', 'Closure'),
    ('order', 'Order')
]

base_dir = '/Users/tchitchi/Desktop/crm app/crm_app_smmart/lib/features/spanco'
suspecting_ctrl = f'{base_dir}/suspecting/controller/suspecting_controller.dart'
suspecting_screen = f'{base_dir}/suspecting/view/suspecting_details_screen.dart'

with open(suspecting_ctrl, 'r') as f:
    ctrl_data = f.read()

with open(suspecting_screen, 'r') as f:
    screen_data = f.read()

# For controller, remove:
#   bool isMoveLoading = false;
# ... 
#   Future<void> moveToProspecting() async { ... }
start_idx = ctrl_data.find('bool isMoveLoading = false;')
end_idx = ctrl_data.rfind('}') # Very last bracket

clean_ctrl = ctrl_data[:start_idx] + '}\n'

# For view, remove:
# if (!controller.isEditing)
#   ElevatedButton(
#     ...
#     onPressed: () { controller.moveToProspecting(); },
#     ...
# ),
start_idx_view = screen_data.find('if (!controller.isEditing)')
end_idx_view = screen_data.find('],', start_idx_view) # where column children ends
if start_idx_view != -1 and end_idx_view != -1:
    clean_view = screen_data[:start_idx_view] + screen_data[end_idx_view:]
else:
    clean_view = screen_data

for lower, upper in stages:
    # process controller
    c_data = clean_ctrl.replace('Suspecting', upper).replace('suspecting', lower)
    c_path = f'{base_dir}/{lower}/controller/{lower}_controller.dart'
    with open(c_path, 'w') as f:
        f.write(c_data)
        
    # process screen
    s_data = clean_view.replace('Suspecting', upper).replace('suspecting', lower)
    s_path = f'{base_dir}/{lower}/view/{lower}_details_screen.dart'
    with open(s_path, 'w') as f:
        f.write(s_data)
        
print("Fixed.")
