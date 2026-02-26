import os
import re

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

# Remove move to prospecting logic from controller
ctrl_data = re.sub(r'\s*bool isMoveLoading = false;\s*Future<void> moveToProspecting\(\) async \{.*?\n  \}\n', '', ctrl_data, flags=re.DOTALL)

# Remove move to prospecting button from screen
screen_data = re.sub(r'\s*if \(\!controller\.isEditing\)\s*ElevatedButton\(\s*style: ElevatedButton\.styleFrom\(.*?onPressed: \(\) \{\s*controller\.moveToProspecting\(\);\s*\},.*?Text\(\'Move to Prospecting\'.*?\),.*?\},.*?\),', '', screen_data, flags=re.DOTALL)


for lower, upper in stages:
    # process controller
    c_data = ctrl_data.replace('Suspecting', upper).replace('suspecting', lower)
    c_path = f'{base_dir}/{lower}/controller/{lower}_controller.dart'
    with open(c_path, 'w') as f:
        f.write(c_data)
        
    # process screen
    s_data = screen_data.replace('Suspecting', upper).replace('suspecting', lower)
    s_path = f'{base_dir}/{lower}/view/{lower}_details_screen.dart'
    with open(s_path, 'w') as f:
        f.write(s_data)
        
print("Updated all stages.")
