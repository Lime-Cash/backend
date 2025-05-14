#!/bin/bash

curl -X GET \
  http://localhost:3000/my_balance \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiZGM4YjZkYzItNTc3YS00YTMzLWE5OWYtZDQ1MWEyYmFlYmI2In0.NtjY7J5HGqkAjN1pmjzPUBWnqoeKpfKwOYhVpC2r5Xw' \
  -H 'Content-Type: application/json' 