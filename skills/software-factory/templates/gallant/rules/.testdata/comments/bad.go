package isbn

// Canonical returns the ISBN-10 form of s.
func Canonical(s string) (string, error) {
	return toISBN13(s)
}

// Add adds.
func Add(a, b int) int { return a + b }
