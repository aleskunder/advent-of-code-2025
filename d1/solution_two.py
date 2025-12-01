INITIAL_VAL = 50
CIRCLE_SIZE = 100
INPUT_PATH = 'input.txt'


def read_input():
    with open(INPUT_PATH, 'r') as file:
        data = [line.strip() for line in file.readlines()]
        int_data = [int(line[1:]) if line[0] == 'R' else -
                    int(line[1:]) for line in data]  # now direction matters
    return int_data


def count_passing_zeros(int_list: list, initial_value: int = INITIAL_VAL, clock_size: int = CIRCLE_SIZE):
    k = initial_value
    z = int(k == 0)

    for val in int_list:
        k += val
        if k < 0:
            if val == k:
                z -= 1  # if we start from zero, we have already counted 'passing' on the prev step
            # count how many 0s crossed (neg and one-based)
            z -= k // clock_size
            k = k % clock_size  # keep k within 0 - clock_size-1
            if k == 0:            # <-- patch: count zero if landed exactly at 0
                z += 1

        elif k >= clock_size:
            # count how many 0s crossed (pos and zero-based)
            z += k // clock_size
            k = k % clock_size  # keep k within 0 - clock_size-1
        elif k == 0:
            z += 1
    return z


def dummy_count_passing_zeros(int_list: list, initial_value: int = INITIAL_VAL, clock_size: int = CIRCLE_SIZE):
    k = initial_value
    z = int(k == 0)

    for val in int_list:
        k += val
        if k == 0:
            z += 1
        while k < 0:
            if k != val:
                z += 1
            k += clock_size
            if k == 0:
                z += 1
        while k >= clock_size:
            k -= clock_size
            z += 1
    return z


def main():
    input_data = read_input()
    print(dummy_count_passing_zeros(input_data))


if __name__ == "__main__":
    main()
