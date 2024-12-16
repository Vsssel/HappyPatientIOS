Happy Patient is a service where patient can create account, search for a doctors, view information about doctors and see free slots for them, make appointment for a doctors and view medical records
Functions: 
1. Create account and access to the service
   1.1 Sending  verification code to email POST http://64.225.71.203:2222/patient/auth
   1.2 Creating account and verify email POST http://64.225.71.203:2222/patient/auth/sign-up
2. Logging in to service by iin or email and password POST http://64.225.71.203:2222/auth
3. Search for doctors by name, doctor's category, location, minimum experience years and sort by name, experience in acs or desc order GET http://64.225.71.203:2222/patient/doctors
4. View doctors information
   4.1 View information about doctors experince, education and price GET  http://64.225.71.203:2222/patient/doctors/{id}
   4.2 View free slots for selected date and appointment type (visit, treatement) GET http://64.225.71.203:2222/patient/doctors/{id}/day/{date}
5. Make appointment to a doctor by selecting a date, appointment type (visit, treatement) and free slot POST http://64.225.71.203:2222/patient/appointments
6. Edit made appointment for a doctor PUT http://64.225.71.203:2222/patient/appointments/{id}
7. Delete made appointment for a doctor DELETE http://64.225.71.203:2222/patient/appointments/{id}
8. View made appointment list by upcoming and past GET http://64.225.71.203:2222/patient/appointments
9. View medical records that are made by doctors GET http://64.225.71.203:2222/patient/medical-records


Youtube link: https://youtu.be/-3oVaNeGzgQ
https://youtu.be/iXV6Q2cf8Ds
