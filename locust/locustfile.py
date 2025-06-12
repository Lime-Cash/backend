from locust import HttpUser, task, between
import csv
import threading
import random

class RailsAPIUser(HttpUser):
  wait_time = between(1, 3)
  token = None
  users = []
  user_lock = threading.Lock()
  user_index = 0

  @classmethod
  def load_users(cls):
      if not cls.users:
          with open("users.csv") as f:
              reader = csv.DictReader(f)
              cls.users = list(reader)

  def on_start(self):
      self.load_users()
      with self.user_lock:
          user = self.users[self.user_index % len(self.users)]
          self.__class__.user_index += 1
      self.email = user["email"]
      self.password = user["password"]

  def ensure_login(self):
      if not self.token:
          self.login_user()

  def get_auth_headers(self):
    if self.token:
      return {
        "Authorization": f"Bearer {self.token}",
        "Content-Type": "application/json"
      }
    return {"Content-Type": "application/json"}
  
  @task(2)
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

  @task(5)
  def get_balance(self):
    self.ensure_login()
    self.client.get("/balance", headers=self.get_auth_headers())
  
  @task(5)
  def get_activity(self):
    self.ensure_login()
    self.client.get("/activity", headers=self.get_auth_headers())
  
  @task(2)
  def create_transfer(self):
    self.ensure_login()
    payload = {
      "email": f"testuser{random.randint(1, 2000)}@test.com",
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
    self.ensure_login()
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
    self.ensure_login()
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