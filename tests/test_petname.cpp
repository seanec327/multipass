/*
 * Copyright (C) Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Alberto Aguirre <alberto.aguirre@canonical.com>
 *
 */

#include "common.h"

#include <src/petname/names_and_adjectives.h>
#include <src/petname/petname.h>

#include <regex>
#include <vector>

namespace mp = multipass;

using namespace testing;

namespace
{
std::vector<std::string> split(const std::string& string)
{
    std::regex regex{"-"};
    return {std::sregex_token_iterator{string.begin(), string.end(), regex, -1}, std::sregex_token_iterator{}};
}
} // namespace

TEST(Petname, generates_adjective_dash_noun)
{
    mp::Petname generator{};

    const auto name = generator.make_name();
    const auto tokens = split(name);
    EXPECT_EQ(tokens.size(), 2);
    EXPECT_THAT(mp::petname::adjectives, Contains(tokens[0]));
    EXPECT_THAT(mp::petname::names, Contains(tokens[1]));
}
