from locust import HttpUser, task, between
import random
import string

class RailsAPIUser(HttpUser):
  wait_time = between(1, 3)
  token = None

  def on_start(self):
    self.register_user()
    self.login_user()
  
  def register_user(self):
    name = ''.join(random.choices(string.ascii_lowercase, k=8))
    email = f"{name}@test.com"
    password = "Password123!"
    
    payload = {
      "name": name,
      "email": email,
      "password": password
    }
    
    self.username = name
    self.email = email
    self.password = password
    
    with self.client.post("/register", 
               json=payload, 
               headers={"Content-Type": "application/json"},
               catch_response=True) as response:
      if response.status_code in [200, 201]:
        response.success()
        data = response.json()
        if 'token' in data:
          self.token = data['token']
      else:
        response.failure(f"Registration failed: {response.status_code}")
  
  def login_user(self):
    payload = {
      "email": self.email,
      "password": self.password
    }
    
    with self.client.post("/login", 
               json=payload, 
               headers={"Content-Type": "application/json"},
               catch_response=True) as response:
      if response.status_code == 200:
        response.success()
        data = response.json()
        if 'token' in data:
          self.token = data['token']
      else:
        response.failure(f"Login failed: {response.status_code}")
  
  def get_auth_headers(self):
    if self.token:
      return {
        "Authorization": f"Bearer {self.token}",
        "Content-Type": "application/json"
      }
    return {"Content-Type": "application/json"}
  
  
  @task(5)
  def get_balance(self):
    self.client.get("/balance", headers=self.get_auth_headers())
  
  @task(5)
  def get_activity(self):
    self.client.get("/activity", headers=self.get_auth_headers())
  
  @task(2)
  def create_transfer(self):
    payload = {
      "email": "johndoe@mail.com",
      "amount": round(random.uniform(1, 130), 2),
    }
    
    with self.client.post("/transfer", 
               json=payload, 
               headers=self.get_auth_headers(),
               catch_response=True) as response:
      if response.status_code in [200, 201, 422, 404]:
        response.success()
      else:
        response.failure(f"Transfer failed: {response.status_code}")
  
  @task(1)
  def create_deposit(self):
    payload = {
      "cbu": "1234567890123456789012",
      "amount": round(random.uniform(1, 130), 2),
    }
    
    with self.client.post("/deposit_bank", 
               json=payload, 
               headers=self.get_auth_headers(),
               catch_response=True) as response:
      if response.status_code in [200, 201, 422]:
        response.success()
      else:
        response.failure(f"Deposit failed: {response.status_code}")
  
  @task(1)
  def create_withdrawal(self):
    payload = {
      "cbu": "1234567890123456789012",
      "amount": round(random.uniform(1, 130), 2),
    }
    
    with self.client.post("/withdraw_bank", 
               json=payload, 
               headers=self.get_auth_headers(),
               catch_response=True) as response:
      if response.status_code in [200, 201, 422]:
        response.success()
      else:
        response.failure(f"Withdrawal failed: {response.status_code}")