package isbn

// Canonical returns the ISBN-13 form of s.
//
// It accepts ISBN-10 and ISBN-13 input, ignores hyphens and spaces, and rejects
// input whose check digit is invalid. A 979-prefixed ISBN has no ISBN-10 form,
// so it is already canonical.
func Canonical(s string) (string, error) {
	digits, err := normalize(s)
	if err != nil {
		return "", err
	}
	return toISBN13(digits)
}
