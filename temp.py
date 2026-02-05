import time
import random
import string

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager

# ----------------------------
# Setup driver
# ----------------------------
options = webdriver.ChromeOptions()
options.add_argument("--start-maximized")

driver = webdriver.Chrome(
    service=Service(ChromeDriverManager().install()),
    options=options
)

wait = WebDriverWait(driver, 20)
actions = ActionChains(driver)

# ----------------------------
# Open Monkeytype
# ----------------------------
driver.get("https://monkeytype.com")
time.sleep(6)

# ----------------------------
# Accept cookies (if shown)
# ----------------------------
try:
    wait.until(
        EC.element_to_be_clickable((By.ID, "cookiePopupAcceptAll"))
    ).click()
except:
    pass

# ----------------------------
# Click your config button (JS click)
# ----------------------------
btn = wait.until(
    EC.presence_of_element_located(
        (By.XPATH, '//*[@id="testConfig"]/div/div[6]/button[1]')
    )
)
driver.execute_script("arguments[0].scrollIntoView(true);", btn)
driver.execute_script("arguments[0].click();", btn)

time.sleep(2)

# ----------------------------
# FORCE FOCUS (CRITICAL)
# ----------------------------
driver.execute_script("window.focus();")
driver.execute_script("document.body.click();")
time.sleep(1)

# ----------------------------
# Typing settings
# ----------------------------
WORD_LIMIT = 50
DELAY_RANGE = (0.03, 0.06)

# ----------------------------
# TYPE USING ACTIONCHAINS (REAL KEYS)
# ----------------------------
for _ in range(WORD_LIMIT):
    word = ''.join(random.choices(string.ascii_lowercase, k=random.randint(3, 7)))

    for char in word:
        actions.send_keys(char).perform()
        time.sleep(random.uniform(*DELAY_RANGE))

    actions.send_keys(Keys.SPACE).perform()
    time.sleep(random.uniform(*DELAY_RANGE))

# ----------------------------
# Done
# ----------------------------
time.sleep(5)
driver.quit()
