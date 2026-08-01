import pytest

def divide(a, b):
    return a/b

@pytest.mark.parametrize("a,b,exp",[
    (5,1,5),
    (10,5,2),
    (3,3,1),
])
def test_divideFunc_normal(a,b,exp):
    result = divide(a,b)
    assert result == exp
@pytest.mark.parametrize("a,b",[
    (5,0),
    (10000,0),
    (1,0),
    (0,0),
])
def test_divideFunc_zero(a,b):
    with pytest.raises(ZeroDivisionError):
        divide(a,b)