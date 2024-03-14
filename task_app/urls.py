from django.urls import path
from .views import TaskReorder, taskDelete, taskList, taskUpdate, userLoginView, userRegisterPage
from .views import taskDetail
from .views import taskCreate
from django.contrib.auth.views import LogoutView
from . import views
from django.conf.urls import url, include

urlpatterns = [
    #Home
    path('', taskList.as_view(), name='tasks'), 

    #Login URL 
    path('login/', userLoginView.as_view(), name='login'),
    path('register/', userRegisterPage.as_view(), name='register'),

    #Logout URL
    path('logout/', LogoutView.as_view(next_page = 'login'), name='logout'),

    #CRUD Functionality
    path('task/<int:pk>/', taskDetail.as_view(), name='task'),
    path('tasks-list/', taskList.as_view(), name='tasks-list'),
    path('create-task/', views.taskCreate, name='task-create'),
    path('update-task/<int:pk>/', taskUpdate.as_view(), name='task-update'),
    path('delete-task/<int:pk>/', taskDelete.as_view(), name='task-delete'),
    path('task-reorder/', TaskReorder.as_view(), name='task-reorder'),
    

    

]