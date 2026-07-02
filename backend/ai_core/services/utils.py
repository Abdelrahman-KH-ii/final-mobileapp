from farms.models import Farm
from ai_core.models import AICoreResult


def process_ai_request(user, serializer, model_type, ai_function):
    """
    Process AI request and save result to database.
    
    Args:
        user: The authenticated user making the request
        serializer: The validated serializer with input data
        model_type: The type of AI model being used
        ai_function: The function to execute for prediction
    
    Returns:
        The result from the AI function
    """
    farm = Farm.objects.get(
        id=serializer.validated_data["farm_id"],
        user=user
    )

    result = ai_function(serializer.validated_data)

    AICoreResult.objects.create(
        user=user,
        farm=farm,
        model_type=model_type,
        input_data=serializer.validated_data,
        result_data=result
    )

    return result