import random
from rest_framework.decorators import api_view

from rest_framework.response import Response


@api_view(['POST'])
def start(request):
    response = dict(
        color="#123456",
        name="Snake Name"
    )
    return Response(response)


@api_view(['POST'])
def move(request):
    moves = ['up', 'down', 'left', 'right']
    move = random.choice(moves)
    response = dict(
        move=move
    )
    return Response(response)
