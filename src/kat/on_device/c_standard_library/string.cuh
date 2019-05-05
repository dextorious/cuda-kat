/**
 * @file string.h CUDA device-side versions of the C standard library string operations.
 *
 * @note The implementations are not intended to be particularly speedy - merely functional.
 *
 * @note unimplemented functions: strcoll, strxfrm (these require a locale); strerror (errno
 * errors are not generated by device-side code); strtok (not reentrant)
 */
#pragma once
#ifndef CUDAT_KAT_ON_DEVICE_C_STANDARD_LIBRARY_EQUIVALENTS_STRING_H_
#define CUDAT_KAT_ON_DEVICE_C_STANDARD_LIBRARY_EQUIVALENTS_STRING_H_

#include "common.cuh"

#include <kat/define_specifiers.hpp>

namespace kat {

namespace c_std_lib {

using size_t = std::size_t;

inline __device__
int strcmp(const char* lhs, const char* rhs)
{
	do {
		if (*lhs > *rhs) { return  1; }
		if (*rhs < *lhs) { return -1; }
		lhs++, rhs++;
	} while(*lhs != '\0');
	return 0;
}

inline __device__
int strncmp(const char* lhs, const char* rhs, size_t n)
{
	for(size_t i = 0; i < n; i++) {
		if (lhs[i] > rhs[i]) { return  1; }
		if (rhs[i] < lhs[i]) { return -1; }
		if (lhs[i] == '\0') { break; }
	}
	return 0;
}

inline __device__
int memcmp(const void* lhs, const void* rhs, size_t n)
{
	const char* lhs_as_chars;
	const char* rhs_as_chars;
	for(size_t i = 0; i < n; i++) {
		if (lhs_as_chars[i] > rhs_as_chars[i]) { return  1; }
		if (rhs_as_chars[i] < lhs_as_chars[i]) { return -1; }
	}
	return 0;
}

inline __device__
char* strcpy(char *dst, const char *src)
{
	while (*dst != '\0') { *(dst++) = *(src++); }
	*dst = *src;
	return dst;
}

inline __device__
char* strncpy(char *dst, const char *src, size_t n)
{
	for(size_t i = 0; i < n && *dst != '\0'; i++, src++, dst++) {
		*dst = *src;
	}
	return dst;
}

inline __device__
std::size_t strlen(const char *s)
{
	char* p = s;
	while(*p != '\0') { p++; }
	return p - s;
}

inline __device__
char *strcat(char *dest, const char *src)
{
	return strcpy(dest + strlen(dest), src);
}

inline __device__
char *strncat(char *dest, const char *src, size_t n)
{
	return strncpy(dest + strlen(dest), src, n);
}

inline __device__
void* memcpy(
	void*        __restrict__  destination,
	const void*  __restrict__  source,
	size_t                     size)
{
	return ::memcpy(destination, source, size);
}

inline __device__
void* memset(void* destination, int c, size_t size)
{
	::memset(destination, c, size);
	return destination;
}

inline __device__
void *memchr(const void *s, int c, size_t n)
{
	for(const char* p = s; p < s + n; p++) {
		if (*p == c) { return p; }
	}
	return nullptr;
}

inline __device__
char *strchr(const char *s, int c)
{
	for(const char* p = s; *p != '\0'; p++) {
		if (*p == c) { return p; }
	}
	return nullptr;
}

inline __device__
char *strrchr(const char *s, int c)
{
	const char* last = nullptr;
	for(const char* p = s ; *p != '\0'; p++) {
		if (*p == c) { last = p; }
	}
	return last;
}

// Naive implementation!
inline __device__
char *strpbrk(const char *s, const char *accept)
{
	for(const char* p = s; *p != '\0'; *p++) {
		if (strchr(accept, *p)) { return p; }
	}
	return nullptr;
}

// Naive implementation!
inline __device__
size_t strspn(const char *s, const char *accept)
{
	const char* p = s;
	while(*p != '\0' && strchr(accept, p)) { p++; }
	return p - s;
}

// Naive implementation!
inline __device__
size_t strcspn(const char *s, const char *reject)
{
	const char* p = s;
	while(*p != '\0' && !strchr(reject, p)) { p++; }
	return p - s;
}

// Naive O(|haystack| * |needle|) implementation!
inline __device__
char *strstr(const char *haystack, const char *needle)
{
	size_t needle_length = strlen(needle);
	size_t haystack_length = strlen(haystack);
	if (haystack_length < needle_length) { return nullptr; }
	const char* last_possible_location = haystack + haystack_length - needle_length;
	const char* p = haystack;
	do {
		size_t i = 0;
		while (i < needle_length) {
			if (p[i] == needle[i]) { break; }
			i++;
		}
		bool found_match = (i != needle_length);
		if (found_match) { return true; }
		p++;
	} while (p <= last_possible_location);
	return nullptr;
}

// Naive O(|haystack| * |needle|) implementation!
inline __device__
char *strrstr(const char *haystack, const char *needle)
{
	size_t needle_length   = strlen(needle);
	size_t haystack_length = strlen(haystack);
	if (haystack_length < needle_length) { return nullptr; }
	const char* p = haystack - needle_length;
	do {
		size_t i = 0;
		while (i < needle_length) {
			if (p[i] == needle[i]) { break; }
			i++;
		}
		bool found_match = (i != needle_length);
		if (found_match) { return true; }
		p--;
	} while (p >= haystack); // This assumes haystack is not 0.
	return nullptr;
}



} // namespace c_std_lib

} // namespace kat


#include <kat/undefine_specifiers.hpp>

#endif // CUDAT_KAT_ON_DEVICE_C_STANDARD_LIBRARY_EQUIVALENTS_STRING_H_