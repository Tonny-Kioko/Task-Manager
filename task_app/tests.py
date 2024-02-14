from django.test import TestCase
from django.contrib.auth.models import User
from django.test import RequestFactory
from django.urls import reverse
from .models import Task
from .views import taskCreate, taskList, taskDetail, taskUpdate, taskDelete


class TaskModelTestCase(TestCase):
    @classmethod
    def setUpTestData(cls):
        # Create a user
        cls.user = User.objects.create_user(username='testuser', password='testpassword')

        # Create a sample task
        cls.task = Task.objects.create(
            user=cls.user,
            title='Sample Task',
            description='This is a sample task description.',
            image=None,
            complete=False,
        )

    def test_task_creation(self):
        # Retrieve the created task from the database
        task = Task.objects.get(id=self.task.id)

        # Test that the task has been created correctly
        self.assertEqual(task.user, self.user)
        self.assertEqual(task.title, 'Sample Task')
        self.assertEqual(task.description, 'This is a sample task description.')
        self.assertIsNone(task.image)
        self.assertFalse(task.complete)
        self.assertIsNotNone(task.created)

    def test_task_str_method(self):
        # Test the __str__ method of the Task model
        task = Task.objects.get(id=self.task.id)
        self.assertEqual(str(task), 'Sample Task')


class TaskViewsTestCase(TestCase):
    def setUp(self):
        # Create a test user
        self.user = User.objects.create_user(username='testuser', password='password')

        # Create a test task
        self.task = Task.objects.create(
            user=self.user,
            title='Test Task',
            description='This is a test task.',
            complete=False,
        )

        self.factory = RequestFactory()

    def test_task_create_view(self):
        # Create a POST request to the taskCreate view
        request = self.factory.post(reverse('task-create'), data={
            'title': 'New Task',
            'description': 'This is a new task.',
            'complete': False,
        })

        # Set the user attribute on the request to simulate an authenticated user
        request.user = self.user

        # Call the taskCreate view
        response = taskCreate(request)

        # Check that the task was created successfully (status code 302 indicates redirect)
        self.assertEqual(response.status_code, 302)

        # Check that the task was actually created in the database
        self.assertTrue(Task.objects.filter(title='New Task').exists())

    def test_task_list_view(self):
        # Create a GET request to the taskList view
        request = self.factory.get(reverse('task-list'))

        # Set the user attribute on the request to simulate an authenticated user
        request.user = self.user

        # Call the taskList view
        response = taskList.as_view()(request)

        # Check that the response contains the test task
        self.assertIn(self.task, response.context_data['object_list'])

    def test_task_detail_view(self):
        # Create a GET request to the taskDetail view for the test task
        request = self.factory.get(reverse('task-detail', kwargs={'pk': self.task.pk}))

        # Set the user attribute on the request to simulate an authenticated user
        request.user = self.user

        # Call the taskDetail view
        response = taskDetail.as_view()(request, pk=self.task.pk)

        # Check that the response contains the test task
        self.assertEqual(response.context_data['task'], self.task)

    def test_task_update_view(self):
        # Create a POST request to the taskUpdate view for updating the test task
        request = self.factory.post(reverse('task-update', kwargs={'pk': self.task.pk}), data={
            'title': 'Updated Task',
            'description': 'This is an updated task.',
            'complete': True,
        })

        # Set the user attribute on the request to simulate an authenticated user
        request.user = self.user

        # Call the taskUpdate view
        response = taskUpdate.as_view()(request, pk=self.task.pk)

        # Check that the task was updated successfully (status code 302 indicates redirect)
        self.assertEqual(response.status_code, 302)

        # Refresh the test task from the database
        self.task.refresh_from_db()

        # Check that the task attributes were updated correctly
        self.assertEqual(self.task.title, 'Updated Task')
        self.assertEqual(self.task.description, 'This is an updated task.')
        self.assertTrue(self.task.complete)

    def test_task_delete_view(self):
        # Create a POST request to the taskDelete view for deleting the test task
        request = self.factory.post(reverse('task-delete', kwargs={'pk': self.task.pk}))

        # Set the user attribute on the request to simulate an authenticated user
        request.user = self.user

        # Call the taskDelete view
        response = taskDelete.as_view()(request, pk=self.task.pk)

        # Check that the task was deleted successfully (status code 302 indicates redirect)
        self.assertEqual(response.status_code, 302)

        # Check that the test task no longer exists in the database
        self.assertFalse(Task.objects.filter(pk=self.task.pk).exists())
